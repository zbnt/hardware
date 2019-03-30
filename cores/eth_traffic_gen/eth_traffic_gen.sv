/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen #(parameter mem_addr_width = 6, parameter mem_size = 4)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [31:0] s_axi_wdata,
	input logic [3:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// M_AXIS : AXI4-Stream master interface (to TEMAC)

	input logic m_axis_clk,
	input logic m_axis_reset,

	output logic [31:0] m_axis_tdata,
	output logic [3:0] m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// MEM_A : Memory port A (read/written by S_AXI)

	output logic [mem_addr_width-1:0] mem_a_addr,
	output logic [7:0] mem_a_wdata,
	output logic mem_a_we,
	input logic [7:0] mem_a_rdata,

	// MEM_B : Memory port B (read by M_AXIS)

	output logic [mem_addr_width-1:0] mem_b_addr,
	input logic [7:0] mem_b_rdata,

	// IFG control (to TEMAC)

	output logic [7:0] ifg_delay
);
	logic [31:0] reg_val[0:1];

	eth_traffic_gen_axi U0 #(mem_addr_width, mem_size, 4, 2)
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

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

		.mem_a_addr(mem_a_addr),
		.mem_a_wdata(mem_a_wdata),
		.mem_a_we(mem_a_we),
		.mem_a_rdata(mem_a_rdata),

		.reg_val(reg_val),
		.reg_in(reg_val)
	);

	eth_traffic_gen_axis U1 #(mem_addr_width, mem_size)
	(
		.clk(m_axis_clk),
		.rst(m_axis_reset),

		.enable(reg_val[0][0]),
		.headers_size(reg_val[1][15:0]),
		.payload_size(reg_val[1][31:16]),

		.mem_addr(mem_b_addr),
		.mem_rdata(mem_b_rdata),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);
endmodule

