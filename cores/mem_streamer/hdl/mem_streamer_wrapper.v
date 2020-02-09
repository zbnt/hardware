/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mem_streamer_w
#(
	parameter C_MEM_SIZE = 4,
	parameter C_DATA_WIDTH = 8,
	parameter C_DELAY_TIME = 12
)
(
	// Clock and reset

	input wire clk,
	input wire rst_n,

	// MEM : Memory interface (DRAM/BRAM)

	output wire mem_clk,
	output wire mem_rst,
	output wire mem_en,
	output wire mem_we,
	output wire [$clog2(C_MEM_SIZE)-1:0] mem_addr,
	input wire [C_DATA_WIDTH-1:0] mem_rdata,

	// M_AXIS : AXI4-Stream master interface

	output wire [C_DATA_WIDTH-1:0] m_axis_tdata,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready
);
	assign mem_clk = clk;
	assign mem_rst = ~rst_n;
	assign mem_en = 1'b1;
	assign mem_we = 1'b0;

	mem_streamer #(C_MEM_SIZE, C_DATA_WIDTH, C_DELAY_TIME) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		// MEM

		.mem_addr(mem_addr),
		.mem_rdata(mem_rdata),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);
endmodule

