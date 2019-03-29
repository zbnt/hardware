/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_w #(parameter mem_addr_width = 6, parameter mem_size = 4)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input wire s_axi_clk,
	input wire s_axi_resetn,

	input wire [11:0] s_axi_awaddr,
	input wire [2:0] s_axi_awprot,
	input wire s_axi_awvalid,
	output wire s_axi_awready,

	input wire [31:0] s_axi_wdata,
	input wire [3:0] s_axi_wstrb,
	input wire s_axi_wvalid,
	output wire s_axi_wready,

	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,

	input wire [11:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [31:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// M_AXIS : AXI4-Stream master interface (to TEMAC)

	input wire m_axis_clk,
	input wire m_axis_reset,

	output wire [31:0] m_axis_tdata,
	output wire [3:0] m_axis_tkeep,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready,

	// MEM_A : Memory port A (read/written by S_AXI)

	output wire [mem_addr_width-1:0] mem_a_addr,
	output wire [7:0] mem_a_wdata,
	output wire mem_a_we,
	input wire [7:0] mem_a_rdata,

	// MEM_B : Memory port B (read by M_AXIS)

	output wire [mem_addr_width-1:0] mem_b_addr,
	input wire [7:0] mem_b_rdata,

	// IFG control (to TEMAC)

	output wire [7:0] ifg_delay
);
	eth_traffic_gen U0 #(mem_addr_width, mem_size)
	(
		// S_AXI

		.s_axi_clk(s_axi_clk),
		.s_axi_resetn(s_axi_resetn),

		.s_axi_awaddr(s_axi_awaddr),
		.s_axi_awprot(s_axi_awprot),
		.s_axi_awvalid(s_axi_awvalid),
		.s_axi_awready(s_axi_awready),

		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),

		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),

		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready),

		// M_AXIS

		.m_axis_clk(m_axis_clk),
		.m_axis_reset(m_axis_reset),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		// MEM_A

		.mem_a_addr(mem_a_addr),
		.mem_a_wdata(mem_a_wdata),
		.mem_a_we(mem_a_we),
		.mem_a_rdata(mem_a_rdata),

		// MEM_B

		.mem_b_addr(mem_b_addr),
		.mem_b_rdata(mem_b_rdata),

		// IFG control

		.ifg_delay(ifg_delay)
	);
endmodule

