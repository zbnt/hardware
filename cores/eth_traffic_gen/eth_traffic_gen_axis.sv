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

	// MEM

	output logic [7:0] mem_addr,
	input logic [7:0] mem_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_SEND_HEADERS, ST_SEND_PAYLOAD, ST_SEND_FCS} state, state_next;
	logic [15:0] count, count_next;

	logic [7:0] mem_addr_next;
	logic [7:0] m_axis_tdata_next;
	logic m_axis_tlast_next;
	logic m_axis_tvalid_next;

	logic [63:0] lfsr_val;
	logic [31:0] crc32_val;
	logic crc32_enable;

	lfsr_64 U0
	(
		.clk(clk),
		.rst(rst),
		.enable(m_axis_tready),
		.value(lfsr_val)
	);

	crc32b U1
	(
		.clk(clk),
		.rst(rst),
		.enable(crc32_enable),
		.in_byte(m_axis_tdata_next),
		.crc(crc32_val)
	);

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			mem_addr <= '0;

			m_axis_tvalid <= 1'b0;
			m_axis_tdata <= '0;
			m_axis_tlast <= 1'b0;
		end else begin
			mem_addr <= mem_addr_next;

			m_axis_tvalid <= m_axis_tvalid_next;
			m_axis_tdata <= m_axis_tdata_next;
			m_axis_tlast <= m_axis_tlast_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;

		mem_addr_next = mem_addr;
		m_axis_tvalid_next = m_axis_tvalid;
		m_axis_tdata_next = m_axis_tdata;
		m_axis_tlast_next = m_axis_tlast;

		m_axis_tkeep = 1'b1;

		if(~rst) begin
			m_axis_tvalid_next = 1'b1;
			m_axis_tlast_next = 1'b0;

			case(state)
				ST_SEND_HEADERS: begin
					m_axis_tdata_next = mem_rdata;

					if(mem_addr != '0 || enable) begin
						if(m_axis_tready) begin
							if(mem_addr == byte_count - 'd1 || mem_addr == headers_size) begin
								mem_addr_next = '0;
								count_next = 16'd0;
								state_next = ST_SEND_PAYLOAD;
							end else begin
								mem_addr_next = mem_addr + 'd1;
							end
						end
					end else begin
						m_axis_tvalid_next = 1'b0;
					end
				end

				ST_SEND_PAYLOAD: begin
					m_axis_tdata_next = lfsr_val[7:0];

					if(m_axis_tready) begin
						if(count == payload_size - 16'd1) begin
							count_next = 16'd0;
							state_next = ST_SEND_FCS;
						end else begin
							count_next = count + 16'd1;
						end
					end
				end

				ST_SEND_FCS: begin
					case(count[1:0])
						2'd0: m_axis_tdata_next = crc32_val[7:0];
						2'd1: m_axis_tdata_next = crc32_val[15:8];
						2'd2: m_axis_tdata_next = crc32_val[23:16];
						2'd3: m_axis_tdata_next = crc32_val[31:24];
					endcase

					if(m_axis_tready) begin
						if(count == 16'd3) begin
							count_next = 16'd0;
							state_next = ST_SEND_HEADERS;
							m_axis_tlast_next = 1'b1;
						end else begin
							count_next = count + 16'd1;
						end
					end
				end
			endcase
		end
	end
endmodule
