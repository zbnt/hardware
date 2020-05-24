/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_w #(parameter C_AXI_WIDTH = 32, parameter C_AXIS_LOG_ENABLE = 1, parameter C_AXIS_LOG_WIDTH = 64)
(
	// S_AXI : AXI4-Lite slave interface

	input wire s_axi_clk,
	input wire s_axi_resetn,

	input wire [11:0] s_axi_awaddr,
	input wire [2:0] s_axi_awprot,
	input wire s_axi_awvalid,
	output wire s_axi_awready,

	input wire [C_AXI_WIDTH-1:0] s_axi_wdata,
	input wire [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input wire s_axi_wvalid,
	output wire s_axi_wready,

	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,

	input wire [11:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// M_AXIS_MAIN : AXI4-Stream master interface (to MAC of main iface)

	output wire [7:0] m_axis_main_tdata,
	output wire m_axis_main_tuser,
	output wire m_axis_main_tlast,
	output wire m_axis_main_tvalid,
	input wire m_axis_main_tready,

	// S_AXIS_MAIN : AXI4-Stream slave interface (from MAC of main iface)

	input wire s_axis_main_clk,

	input wire [7:0] s_axis_main_tdata,
	input wire s_axis_main_tuser,
	input wire s_axis_main_tlast,
	input wire s_axis_main_tvalid,

	// M_AXIS_LOOP : AXI4-Stream master interface (to MAC of loopback iface)

	output wire [7:0] m_axis_loop_tdata,
	output wire m_axis_loop_tuser,
	output wire m_axis_loop_tlast,
	output wire m_axis_loop_tvalid,
	input wire m_axis_loop_tready,

	// S_AXIS_LOOP : AXI4-Stream slave interface (from MAC of loopback iface)

	input wire s_axis_loop_clk,

	input wire [7:0] s_axis_loop_tdata,
	input wire s_axis_loop_tuser,
	input wire s_axis_loop_tlast,
	input wire s_axis_loop_tvalid,

	// M_AXIS_LOG

	output wire [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output wire m_axis_log_tlast,
	output wire m_axis_log_tvalid,
	input wire m_axis_log_tready,

	// Timer

	input wire [63:0] current_time,
	input wire time_running
);
	eth_latency_measurer #(C_AXI_WIDTH, C_AXIS_LOG_ENABLE, C_AXIS_LOG_WIDTH) U0
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

		// M_AXIS_MAIN

		.m_axis_main_tdata(m_axis_main_tdata),
		.m_axis_main_tuser(m_axis_main_tuser),
		.m_axis_main_tlast(m_axis_main_tlast),
		.m_axis_main_tvalid(m_axis_main_tvalid),
		.m_axis_main_tready(m_axis_main_tready),

		// S_AXIS_MAIN

		.s_axis_main_clk(s_axis_main_clk),

		.s_axis_main_tdata(s_axis_main_tdata),
		.s_axis_main_tuser(s_axis_main_tuser),
		.s_axis_main_tlast(s_axis_main_tlast),
		.s_axis_main_tvalid(s_axis_main_tvalid),

		// M_AXIS_LOOP

		.m_axis_loop_tdata(m_axis_loop_tdata),
		.m_axis_loop_tuser(m_axis_loop_tuser),
		.m_axis_loop_tlast(m_axis_loop_tlast),
		.m_axis_loop_tvalid(m_axis_loop_tvalid),
		.m_axis_loop_tready(m_axis_loop_tready),

		// S_AXIS_LOOP

		.s_axis_loop_clk(s_axis_loop_clk),

		.s_axis_loop_tdata(s_axis_loop_tdata),
		.s_axis_loop_tuser(s_axis_loop_tuser),
		.s_axis_loop_tlast(s_axis_loop_tlast),
		.s_axis_loop_tvalid(s_axis_loop_tvalid),

		// M_AXIS_LOG

		.m_axis_log_tdata(m_axis_log_tdata),
		.m_axis_log_tlast(m_axis_log_tlast),
		.m_axis_log_tvalid(m_axis_log_tvalid),
		.m_axis_log_tready(m_axis_log_tready),

		// Timer

		.current_time(current_time),
		.time_running(time_running)
	);
endmodule
