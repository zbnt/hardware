/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mem_streamer_w #(parameter addr_width = 6, parameter data_width = 8, parameter byte_count = 4)
(
	// Clock and reset

	input wire clk,
	input wire rst,

	// MEM : Memory interface (DRAM/BRAM)

	output wire [addr_width-1:0] mem_addr,
	input wire [data_width-1:0] mem_rdata,

	// M_AXIS : AXI4-Stream master interface

	output wire [data_width-1:0] m_axis_tdata,
	output wire [(data_width/8)-1:0] m_axis_tkeep,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready
);
	mem_streamer #(addr_width, data_width, byte_count) U0
	(
		.clk(clk),
		.rst(rst),

		// MEM

		.mem_addr(mem_addr),
		.mem_rdata(mem_rdata),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);
endmodule

