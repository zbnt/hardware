/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

`timescale 1ns / 1ps

module tcp_traffic_gen_w
(
	// Clock and reset are shared by all interfaces

	input wire axi_clk,
	input wire axi_resetn,

	// S_AXI : AXI4-Lite slave interface (configuration)

	input wire [6:0] s_axi_awaddr,
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

	input wire [6:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [31:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// M_AXIS_TXD : AXI4-Stream master interface (data)

	output wire [31:0] m_axis_txd_tdata,
	output wire [3:0] m_axis_txd_tkeep,
	output wire m_axis_txd_tlast,
	output wire m_axis_txd_tvalid,
	input wire m_axis_txd_tready,

	// M_AXIS_TXC : AXI4-Stream master interface (control)

	output wire [31:0] m_axis_txc_tdata,
	output wire [3:0] m_axis_txc_tkeep,
	output wire m_axis_txc_tlast,
	output wire m_axis_txc_tvalid,
	input wire m_axis_txc_tready
);
	tcp_traffic_gen U0
	(
		.clk(axi_clk),
		.rst_n(axi_resetn),

		// S_AXI

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

		// M_AXIS_TXD

		.m_axis_txd_tdata(m_axis_txd_tdata),
		.m_axis_txd_tkeep(m_axis_txd_tkeep),
		.m_axis_txd_tlast(m_axis_txd_tlast),
		.m_axis_txd_tvalid(m_axis_txd_tvalid),
		.m_axis_txd_tready(m_axis_txd_tready),

		// M_AXIS_TXC

		.m_axis_txc_tdata(m_axis_txc_tdata),
		.m_axis_txc_tkeep(m_axis_txc_tkeep),
		.m_axis_txc_tlast(m_axis_txc_tlast),
		.m_axis_txc_tvalid(m_axis_txc_tvalid),
		.m_axis_txc_tready(m_axis_txc_tready)
	);
endmodule

