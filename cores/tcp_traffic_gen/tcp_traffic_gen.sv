/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

`timescale 1ns / 1ps

module tcp_traffic_gen
(
	input logic clk,
	input logic rst_n,

	// S_AXI : AXI4-Lite slave interface (configuration)

	input logic [6:0] s_axi_awaddr,
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

	input logic [6:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready

	// M_AXIS_TXD : AXI4-Stream master interface (data)

	input logic m_axis_clk,
	input logic m_axis_aresetn,

	output logic [31:0] m_axis_txd_tdata,
	output logic [3:0] m_axis_txd_tkeep,
	output logic m_axis_txd_tlast,
	output logic m_axis_txd_tvalid,
	input logic m_axis_txd_tready,

	// M_AXIS_TXC : AXI4-Stream master interface (control)

	output logic [31:0] m_axis_txc_tdata,
	output logic [3:0] m_axis_txc_tkeep,
	output logic m_axis_txc_tlast,
	output logic m_axis_txc_tvalid,
	input logic m_axis_txc_tready
);
	/*
		Registers:

			0     : Config register
			1     : Length and delay
			2-4   : MAC addresses
			5     : Identification, TTL, flags
			6     : Source IP
			7     : Destination IP
			8     : Ports
			9     : Sequence number
			10    : Data offset, flags, window size
			11    : Urgent pointer
			12-22 : Options
	*/

	logic [31:0] reg_val[0:22];
	logic [31:0] reg_in[0:22];

	axi4_lite_reg_bank #(num_regs, 23, {23{1'b1}}) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.reg_val(reg_val),
		.reg_in(reg_in),

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
		.s_axi_rready(s_axi_rready)
	);
endmodule

