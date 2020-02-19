/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_csum
(
	input logic clk,
	input logic rst_n,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [9:0] s_axis_tuser,  // {ORIG_BYTE, DROP_FRAME, FCS_INVALID}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic [47:0] m_axis_tuser, // {IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, FCS_INVALID}
	output logic m_axis_tlast,
	output logic m_axis_tvalid
);
	enum logic [2:0] {ST_ETHER, ST_IP4, ST_IP6, ST_PAYLOAD, ST_UNKNOWN} state;
	logic [15:0] count, count_total, limit, payload_limit;
	logic [7:0] prot_id;

	logic in_ip_csum, in_tr_csum, in_ip6_protid;
	logic ip_csum_valid, tr_csum_valid;
	logic [15:0] ip_csum_val, tr_csum_val;
	logic [17:0] ip_csum_sum, tr_csum_sum;

	logic [7:0] s_axis_tdata_q;
	logic [47:0] s_axis_tuser_q; // {IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, FCS_INVALID}
	logic s_axis_tlast_q, s_axis_tvalid_q;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_ETHER;

			count <= 16'd0;
			count_total <= 16'd0;

			limit <= 16'd0;
			payload_limit <= 16'd0;
			prot_id <= 8'd0;

			in_ip_csum <= 1'b0;
			in_tr_csum <= 1'b0;
			in_ip6_protid <= 1'b0;

			ip_csum_valid <= 1'b0;
			tr_csum_valid <= 1'b0;

			s_axis_tdata_q <= '0;
			s_axis_tuser_q <= '0;
			s_axis_tlast_q <= 1'b0;
			s_axis_tvalid_q <= 1'b0;

			m_axis_tdata <= '0;
			m_axis_tuser <= '0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;
		end else begin
			s_axis_tdata_q <= s_axis_tdata;
			s_axis_tuser_q[1:0] <= s_axis_tuser[1:0];
			s_axis_tlast_q <= s_axis_tlast;
			s_axis_tvalid_q <= s_axis_tvalid;

			m_axis_tdata <= s_axis_tdata_q;
			m_axis_tuser[15:0] <= s_axis_tuser_q[15:0];
			m_axis_tlast <= s_axis_tlast_q;
			m_axis_tvalid <= s_axis_tvalid_q;

			if(ip_csum_valid) begin
				if(s_axis_tuser_q[47:32] != 16'd0) begin
					m_axis_tuser[47:32] <= s_axis_tuser_q[47:32];
				end else begin
					m_axis_tuser[47:32] <= 16'hFFFF;
				end
			end else begin
				m_axis_tuser[47:32] <= 16'd0;
			end

			if(tr_csum_valid) begin
				if(s_axis_tuser_q[31:16] != 16'd0) begin
					m_axis_tuser[31:16] <= s_axis_tuser_q[31:16];
				end else begin
					m_axis_tuser[31:16] <= 16'hFFFF;
				end
			end else begin
				m_axis_tuser[31:16] <= 16'd0;
			end

			if(s_axis_tvalid) begin
				count <= count + 16'd1;
				count_total <= count_total + 16'd1;

				case(state)
					ST_ETHER: begin
						// detect if we're dealing with IPv4, IPv6 or something unknown

						if(count == 16'd13) begin
							if(s_axis_tdata_q == 8'h08 && s_axis_tdata == 16'h00) begin
								state <= ST_IP4;
								count <= 16'd0;
								limit <= 16'hFFFF;
							end else if(s_axis_tdata_q == 8'h86 && s_axis_tdata == 16'hDD) begin
								state <= ST_IP6;
								count <= 16'd0;
								limit <= 16'd39;
							end else begin
								state <= ST_UNKNOWN;
							end
						end
					end

					ST_IP4: begin
						// extract values

						if(count == 16'd0) begin
							limit <= {2'd0, s_axis_tdata[3:0], 2'd0} - 16'd1;
						end

						if(count == 16'd3) begin
							payload_limit <= {s_axis_tdata_q, s_axis_tdata} - limit;
						end

						if(count == 16'd9) begin
							prot_id <= s_axis_tdata;
						end

						// update checksums

						s_axis_tuser_q[47:32] <= ip_csum_val;
						ip_csum_valid <= 1'b1;

						if(count == 16'd0) begin
							s_axis_tuser_q[31:16] <= ~{2'd0, s_axis_tdata[3:0], 2'd0};
						end

						if(count == 16'd9) begin
							in_ip_csum <= 1'b1;
						end

						if(count == 16'd11) begin
							in_ip_csum <= 1'b0;
						end

						if(count[15:1] == 15'd1 || count == 16'd9 || (count >= 16'd12 && count <= 16'd19)) begin
							s_axis_tuser_q[31:16] <= tr_csum_val;
							tr_csum_valid <= 1'b1;
						end

						// move to next header

						if(count == limit) begin
							count <= 16'd0;
							limit <= payload_limit;

							case(prot_id)
								8'h06: begin
									// TCP
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd8;
								end

								8'h11: begin
									// UDP
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd3;
								end

								8'h01: begin
									// ICMP
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd1;
								end

								default: begin
									state <= ST_UNKNOWN;
								end
							endcase
						end
					end

					ST_IP6: begin
						// extract values

						if(count == 16'd5) begin
							payload_limit <= {s_axis_tdata_q, s_axis_tdata};
							in_ip6_protid <= 1'b1;
							count <= 16'd7;
						end

						if(in_ip6_protid) begin
							prot_id <= s_axis_tdata;
							in_ip6_protid <= 1'b0;
							count <= 16'd7;
						end

						// update checksums

						if(count[15:1] == 15'd2 || in_ip6_protid || count >= 16'd8) begin
							s_axis_tuser_q[31:16] <= tr_csum_val;
							tr_csum_valid <= 1'b1;
						end

						// move to next header

						if(count == limit) begin
							count <= 16'd0;
							limit <= payload_limit;

							case(prot_id)
								8'h06: begin
									// TCP
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd8;
								end

								8'h11: begin
									// UDP
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd3;
								end

								8'h3A: begin
									// ICMPv6
									state <= ST_PAYLOAD;
									s_axis_tuser_q[15:2] <= count_total[14:1] + 14'd1;
								end

								default: begin
									state <= ST_UNKNOWN;
								end
							endcase
						end
					end

					ST_PAYLOAD: begin
						s_axis_tuser_q[31:16] <= tr_csum_val;

						if(count == {1'b0, s_axis_tuser_q[15:2], 1'b0} - 16'd1) begin
							in_tr_csum <= 1'b1;
						end

						if(count == {1'b0, s_axis_tuser_q[15:2], 1'b1}) begin
							in_tr_csum <= 1'b0;
						end

						if(count == limit) begin
							state <= ST_UNKNOWN;
						end
					end

					ST_UNKNOWN: begin
						// no-op
					end

					default: begin
						state <= ST_ETHER;
					end
				endcase

				if(s_axis_tlast) begin
					state <= ST_ETHER;

					count <= 16'd0;
					count_total <= 16'd0;

					limit <= 16'd0;
					payload_limit <= 16'd0;
					prot_id <= 8'd0;

					in_ip_csum <= 1'b0;
					in_tr_csum <= 1'b0;
					in_ip6_protid <= 1'b0;

					ip_csum_valid <= 1'b0;
					tr_csum_valid <= 1'b0;
				end
			end
		end
	end

	always_comb begin
		if(~count[0]) begin
			if(~in_ip_csum) begin
				ip_csum_sum = {2'd0, s_axis_tuser_q[47:32]} + {2'd0, s_axis_tdata, 8'd0} + ~{2'd0, s_axis_tuser[9:2], 8'd0};
			end else begin
				ip_csum_sum = {2'd0, s_axis_tuser_q[47:32]} + {2'd0, s_axis_tdata, 8'd0};
			end
		end else begin
			if(~in_ip_csum) begin
				ip_csum_sum = {2'd0, s_axis_tuser_q[47:32]} + {10'd0, s_axis_tdata} + ~{10'd0, s_axis_tuser[9:2]};
			end else begin
				ip_csum_sum = {2'd0, s_axis_tuser_q[47:32]} + {10'd0, s_axis_tdata};
			end
		end

		if(~count[0]) begin
			if(~in_tr_csum) begin
				tr_csum_sum = {2'd0, s_axis_tuser_q[31:16]} + {2'd0, s_axis_tdata, 8'd0} + ~{2'd0, s_axis_tuser[9:2], 8'd0};
			end else begin
				tr_csum_sum = {2'd0, s_axis_tuser_q[31:16]} + {2'd0, s_axis_tdata, 8'd0};
			end
		end else begin
			if(~in_tr_csum) begin
				tr_csum_sum = {2'd0, s_axis_tuser_q[31:16]} + {10'd0, s_axis_tdata} + ~{10'd0, s_axis_tuser[9:2]};
			end else begin
				tr_csum_sum = {2'd0, s_axis_tuser_q[31:16]} + {10'd0, s_axis_tdata};
			end
		end

		ip_csum_val = ip_csum_sum[15:0] + {14'd0, ip_csum_sum[17:16]};
		tr_csum_val = tr_csum_sum[15:0] + {14'd0, tr_csum_sum[17:16]};
	end
endmodule
