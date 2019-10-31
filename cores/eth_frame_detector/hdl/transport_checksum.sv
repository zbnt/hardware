/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module transport_checksum
(
	input logic clk,
	input logic rst_n,

	output logic [15:0] checksum,
	output logic [15:0] checksum_orig,
	output logic [15:0] checksum_pos,
	output logic checksum_done,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	logic [15:0] count;

	logic [7:0] last_byte;
	logic [15:0] checksum_next;
	logic [16:0] checksum_sum;

	logic frame_end, header_valid, ignore_tlast;
	logic [15:0] checksum_data_begin, checksum_data_end;

	enum logic [1:0] {ETH_UNKNOWN, IPV4, IPV6} eth_proto;

	always_ff @(posedge clk) begin
		if(~rst_n | frame_end) begin
			count <= 16'd0;

			last_byte <= 8'd0;
			checksum <= 16'd0;
			checksum_pos <= 16'd0;
			checksum_orig <= 16'd0;
			checksum_done <= 1'b0;

			frame_end <= 1'b0;
			header_valid <= 1'b0;
			ignore_tlast <= 1'b0;
			checksum_data_begin <= 16'd0;
			checksum_data_end <= 16'd0;

			eth_proto <= ETH_UNKNOWN;
		end else if(s_axis_tvalid) begin
			count <= count + 16'd1;
			last_byte <= s_axis_tdata;
			frame_end <= s_axis_tlast;

			if(s_axis_tlast || count == checksum_data_end && checksum_data_end != 16'd0) begin
				if(header_valid) begin
					checksum <= checksum_next;
				end else begin
					checksum <= 16'd0;
				end

				checksum_done <= ~ignore_tlast;
				ignore_tlast <= 1'b1;
			end else begin
				checksum_done <= 1'b0;
			end

			if(count == 16'd13) begin
				if(last_byte == 8'h08 && s_axis_tdata == 16'h00) begin
					eth_proto <= IPV4;
				end else if(last_byte == 8'h86 && s_axis_tdata == 16'hDD) begin
					eth_proto <= IPV6;
				end else begin
					checksum_data_end <= 16'd14;
				end
			end

			if(eth_proto == IPV4 && count == 16'd22 || eth_proto == IPV6 && count == 16'd19) begin
				last_byte <= 8'd0;
			end

			case(eth_proto)
				IPV4: begin
					// subtract IPv4 header length
					if(count == 16'd14) begin
						checksum <= ~{2'd0, s_axis_tdata[3:0], 10'd0};
						checksum_data_begin <= {10'd0, s_axis_tdata[3:0], 2'd0};
					end

					// pseudoheader
					if(count == 16'd17 || count == 16'd23 || (count >= 16'd27 && count <= 16'd33 && count[0])) begin
						checksum <= checksum_next;
					end

					// offset of last IPv4 data byte
					if(count == 16'd17) begin
						checksum_data_end <= {last_byte, s_axis_tdata} + 16'd13;
					end

					// detect protocol, set TCP/UDP/ICMP header offset
					if(count == 16'd23) begin
						if(s_axis_tdata == 8'h06) begin
							// TCP
							checksum_pos <= checksum_data_begin + 16'd31;
							header_valid <= 1'b1;
						end else if(s_axis_tdata == 8'h11) begin
							// UDP
							checksum_pos <= checksum_data_begin + 16'd21;
							header_valid <= 1'b1;
						end else if(s_axis_tdata == 8'h01) begin
							// ICMP
							checksum_pos <= checksum_data_begin + 16'd17;
							header_valid <= 1'b1;
						end else begin
							checksum_data_end <= 16'd24;
						end

						checksum_data_begin <= checksum_data_begin + 16'd15;
					end

					// data, excluding checksum field
					if(count >= checksum_data_begin && count[0] && header_valid) begin
						if(count != checksum_pos) begin
							checksum <= checksum_next;
						end else begin
							checksum_orig <= {s_axis_tdata, last_byte};
						end
					end
				end

				IPV6: begin
					// pseudoheader
					if(count == 16'd19 || count == 16'd20 || (count >= 16'd23 && count <= 16'd53 && count[0])) begin
						checksum <= checksum_next;
					end

					// offset of last IPv6 data byte
					if(count == 16'd19) begin
						checksum_data_end <= {last_byte, s_axis_tdata} + 16'd53;
					end

					// detect protocol, set TCP/UDP/ICMPv6 header offset
					// TODO: Support frames with extension headers
					if(count == 16'd20) begin
						if(s_axis_tdata == 8'h06) begin
							// TCP
							checksum_pos <= 16'd71;
							header_valid <= 1'b1;
						end else if(s_axis_tdata == 8'h11) begin
							// UDP
							checksum_pos <= 16'd61;
							header_valid <= 1'b1;
						end else if(s_axis_tdata == 8'h3A) begin
							// ICMPv6
							checksum_pos <= 16'd57;
							header_valid <= 1'b1;
						end else begin
							checksum_data_end <= 16'd21;
						end

						checksum_data_begin <= checksum_data_begin + 16'd15;
					end

					// data, excluding checksum field
					if(count >= 16'd23 && count[0] && header_valid) begin
						if(count != checksum_pos) begin
							checksum <= checksum_next;
						end else begin
							checksum_orig <= {s_axis_tdata, last_byte};
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		if((s_axis_tlast || count == checksum_data_end && checksum_data_end != 16'd0) && ~count[0]) begin
			// add padding 0 if needed
			checksum_sum = {1'b0, checksum} + {9'd0, s_axis_tdata};
		end else begin
			checksum_sum = {1'b0, checksum} + {1'b0, s_axis_tdata, last_byte};
		end

		if(s_axis_tlast || count == checksum_data_end && checksum_data_end != 16'd0) begin
			// one's complement, avoid all-0 checksum
			if(&checksum_sum[16:1] && ~checksum_sum[0]) begin
				checksum_next = 16'hFFFF;
			end else begin
				checksum_next = ~(checksum_sum[15:0] + {15'd0, checksum_sum[16]});
			end
		end else begin
			checksum_next = checksum_sum[15:0] + {15'd0, checksum_sum[16]};
		end
	end
endmodule
