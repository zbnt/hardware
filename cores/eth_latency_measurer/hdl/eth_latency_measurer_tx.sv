/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_tx #(parameter C_MODE = 0)
(
	input logic clk,
	input logic rst,
	input logic trigger,
	output logic tx_begin,

	// Config

	input logic [47:0] mac_addr_src,
	input logic [31:0] ip_addr_src,

	input logic [47:0] mac_addr_dst,
	input logic [31:0] ip_addr_dst,

	input logic [15:0] padding_size,
	input logic [15:0] frame_id,
	input logic [15:0] log_id,
	input logic [15:0] ping_id,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_TRIGGER, ST_SEND_HEADERS, ST_SEND_PADDING} state, state_next;

	logic [15:0] count, count_next;
	logic [335:0] tx_buffer, tx_buffer_next;
	logic [15:0] ip_checksum, icmp_checksum;

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_WAIT_TRIGGER;
			count <= 16'd0;
			tx_buffer <= '0;
		end else begin
			state <= state_next;
			count <= count_next;
			tx_buffer <= tx_buffer_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		tx_buffer_next = tx_buffer;

		m_axis_tvalid = 1'b0;
		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tuser = 1'b0;

		tx_begin = (state == ST_SEND_HEADERS && count == 16'd0 && m_axis_tready);

		if(~rst) begin
			case(state)
				ST_WAIT_TRIGGER: begin
					m_axis_tvalid = 1'b0;
					m_axis_tdata = 8'd0;
					m_axis_tlast = 1'b0;

					if(trigger) begin
						state_next = ST_SEND_HEADERS;
						count_next = 16'd0;
						tx_buffer_next = {mac_addr_dst, mac_addr_src, 48'h08004500001C, frame_id, 48'h400040010000, ip_addr_src, ip_addr_dst, C_MODE ? 8'h00 : 8'h08, 24'd0, log_id, ping_id};
					end
				end

				ST_SEND_HEADERS: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = tx_buffer[335:328];
					m_axis_tlast = 1'b0;

					if(m_axis_tready) begin
						count_next = count + 16'd1;

						case(count)
							16'd23: begin
								tx_buffer_next = {ip_checksum, tx_buffer[311:0], 8'd0};
							end

							16'd35: begin
								tx_buffer_next = {icmp_checksum, tx_buffer[311:0], 8'd0};
							end

							default: begin
								tx_buffer_next = {tx_buffer[327:0], 8'd0};
							end
						endcase

						if(count >= 16'd41) begin
							count_next = 16'd0;
							state_next = ST_SEND_PADDING;
						end
					end
				end

				ST_SEND_PADDING: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = {4{~count[0], count[0]}};
					m_axis_tlast = (count >= padding_size + 16'd17);

					if(m_axis_tready) begin
						count_next = count + 16'd1;

						if(count >= padding_size + 16'd17) begin
							count_next = 16'd0;
							state_next = ST_WAIT_TRIGGER;
						end
					end
				end

				default: begin
					state_next = ST_WAIT_TRIGGER;
				end
			endcase
		end
	end

	checksum_calculator #(6) U0
	(
		.clk(clk),
		.rst(state == ST_SEND_PADDING | rst),

		.trigger(trigger),

		.values({frame_id, ip_addr_dst, ip_addr_src, 16'hC51D}),
		.checksum(ip_checksum)
	);

	if(C_MODE) begin
		checksum_calculator #(2) U1
		(
			.clk(clk),
			.rst(state == ST_SEND_PADDING | rst),

			.trigger(trigger),

			.values({ping_id, log_id}),
			.checksum(icmp_checksum)
		);
	end else begin
		checksum_calculator #(3) U1
		(
			.clk(clk),
			.rst(state == ST_SEND_PADDING | rst),

			.trigger(trigger),

			.values({ping_id, log_id, 16'h0800}),
			.checksum(icmp_checksum)
		);
	end
endmodule
