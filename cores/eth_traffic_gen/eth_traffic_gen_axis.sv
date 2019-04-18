/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axis #(parameter addr_width = 6, parameter byte_count = 4)
(
	input logic clk,
	input logic rst,
	input logic enable,

	// Config

	input logic [15:0] headers_size,
	input logic [15:0] payload_size,
	input logic [31:0] frame_delay,

	// MEM

	output logic [addr_width-1:0] mem_addr,
	input logic [7:0] mem_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_SEND_HEADERS, ST_SEND_PAYLOAD, ST_FRAME_DELAY} state, state_next;
	logic [31:0] count, count_next;

	logic [7:0] mem_addr_next;
	logic [63:0] lfsr_val;

	lfsr_64 U0
	(
		.clk(clk),
		.rst(rst),
		.enable(m_axis_tready),
		.value(lfsr_val)
	);

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= ST_SEND_HEADERS;
			count <= 32'd0;
			mem_addr <= '0;
		end else begin
			state <= state_next;
			count <= count_next;
			mem_addr <= mem_addr_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		mem_addr_next = mem_addr;

		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tkeep = 1'b1;
		m_axis_tvalid = 1'b1;

		if(~rst) begin
			case(state)
				ST_SEND_HEADERS: begin
					m_axis_tdata = mem_rdata;

					if(mem_addr != '0 || enable) begin
						if(m_axis_tready) begin
							if(mem_addr == byte_count - 'd1 || mem_addr == headers_size - 16'd1) begin
								mem_addr_next = '0;
								count_next = 32'd0;
								state_next = ST_SEND_PAYLOAD;
							end else begin
								mem_addr_next = mem_addr + 'd1;
							end
						end
					end else begin
						m_axis_tvalid = 1'b0;
					end
				end

				ST_SEND_PAYLOAD: begin
					m_axis_tdata = lfsr_val[7:0];

					if(m_axis_tready) begin
						if(count[15:0] == payload_size - 16'd1) begin
							count_next = 32'd0;
							m_axis_tlast = 1'b1;

							if(frame_delay == 32'd0) begin
								state_next = ST_SEND_HEADERS;
							end else begin
								state_next = ST_FRAME_DELAY;
								count_next = 32'd1;
							end
						end else begin
							count_next = count + 32'd1;
						end
					end
				end

				ST_FRAME_DELAY: begin
					m_axis_tvalid = 1'b0;
					count_next = count + 32'd1;

					if(count == frame_delay) begin
						state_next = ST_SEND_HEADERS;
					end
				end

				default: begin
					state_next = ST_SEND_HEADERS;
					m_axis_tvalid = 1'b0;
				end
			endcase
		end
	end
endmodule
