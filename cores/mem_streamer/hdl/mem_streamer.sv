/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mem_streamer
#(
	parameter C_MEM_SIZE = 4,
	parameter C_DATA_WIDTH = 8,
	parameter C_DELAY_TIME = 12
)
(
	input logic clk,
	input logic rst_n,

	// MEM

	output logic [$clog2(C_MEM_SIZE)-1:0] mem_addr,
	input logic [C_DATA_WIDTH-1:0] mem_rdata,

	// M_AXIS

	output logic [C_DATA_WIDTH-1:0] m_axis_tdata,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic {ST_DUMP_MEM, ST_DELAY} state, state_next;
	logic [(C_DELAY_TIME != 0 ? $clog2(C_DELAY_TIME) : 1)-1:0] count, count_next;

	logic [$clog2(C_MEM_SIZE)-1:0] mem_addr_next;
	logic [C_DATA_WIDTH-1:0] m_axis_tdata_next;
	logic m_axis_tlast_next;
	logic m_axis_tvalid_next;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_DUMP_MEM;
			count <= '0;
			mem_addr <= '0;

			m_axis_tvalid <= 1'b0;
			m_axis_tdata <= '0;
			m_axis_tlast <= 1'b0;
		end else begin
			state <= state_next;
			count <= count_next;
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

		case(state)
			ST_DUMP_MEM: begin
				m_axis_tdata_next = mem_rdata;
				m_axis_tvalid_next = 1'b1;

				if(m_axis_tready) begin
					if(mem_addr == C_MEM_SIZE/(C_DATA_WIDTH/8) - 1) begin
						if(C_DELAY_TIME != 0) begin
							state_next = ST_DELAY;
						end

						mem_addr_next = 0;
						m_axis_tlast_next = 1'b1;
					end else begin
						mem_addr_next = mem_addr + 1;
						m_axis_tlast_next = 1'b0;
					end
				end
			end

			ST_DELAY: begin
				m_axis_tdata_next = '0;
				m_axis_tvalid_next = 1'b0;
				m_axis_tlast_next = 1'b0;

				count_next = count + 'd1;
				mem_addr_next = '0;

				if(count == C_DELAY_TIME - 'd1) begin
					state_next = ST_DUMP_MEM;
					count_next = '0;
				end
			end
		endcase
	end
endmodule

