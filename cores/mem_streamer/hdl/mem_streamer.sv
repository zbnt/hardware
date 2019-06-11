/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mem_streamer #(parameter addr_width = 6, parameter data_width = 8, parameter byte_count = 4)
(
	input logic clk,
	input logic rst,

	// MEM

	output logic [addr_width-1:0] mem_addr,
	input logic [data_width-1:0] mem_rdata,

	// M_AXIS

	output logic [data_width-1:0] m_axis_tdata,
	output logic [(data_width/8)-1:0] m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic [addr_width-1:0] mem_addr_next;
	logic [data_width-1:0] m_axis_tdata_next;
	logic [(data_width/8)-1:0] m_axis_tkeep_next;
	logic m_axis_tlast_next;
	logic m_axis_tvalid_next;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			mem_addr <= '0;

			m_axis_tvalid <= 1'b0;
			m_axis_tdata <= '0;
			m_axis_tkeep <= '0;
			m_axis_tlast <= 1'b0;
		end else begin
			mem_addr <= mem_addr_next;

			m_axis_tvalid <= m_axis_tvalid_next;
			m_axis_tdata <= m_axis_tdata_next;
			m_axis_tkeep <= m_axis_tkeep_next;
			m_axis_tlast <= m_axis_tlast_next;
		end
	end

	always_comb begin
		mem_addr_next = mem_addr;
		m_axis_tvalid_next = m_axis_tvalid;
		m_axis_tdata_next = m_axis_tdata;
		m_axis_tkeep_next = m_axis_tkeep;
		m_axis_tlast_next = m_axis_tlast;

		if(~rst) begin
			m_axis_tdata_next = mem_rdata;
			m_axis_tvalid_next = 1'b1;

			if(m_axis_tready) begin
				if(mem_addr == byte_count/(data_width/8) - 1) begin
					mem_addr_next = 0;
					m_axis_tlast_next = 1'b1;

					for(int i = 0; i < data_width/8; ++i) begin
						m_axis_tkeep_next[i] = ((i < byte_count[(data_width/8)-1:0]) || (byte_count[(data_width/8)-1:0] == '0));
					end
				end else begin
					mem_addr_next = mem_addr + 1;
					m_axis_tlast_next = 1'b0;
					m_axis_tkeep_next = '1;
				end
			end
		end
	end
endmodule

