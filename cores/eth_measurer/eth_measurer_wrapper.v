/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_w #(parameter main_mac = 48'hDE_AD_BE_EF_01_01, parameter loop_mac = 48'hDE_AD_BE_EF_01_02, parameter identifier = 32'hCAFECAFE, parameter timeout = 32'd12500000)
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

	// M_AXIS_MAIN : AXI4-Stream master interface (to TEMAC of main iface)

	output wire [7:0] m_axis_main_tdata,
	output wire m_axis_main_tkeep,
	output wire m_axis_main_tlast,
	output wire m_axis_main_tvalid,
	input wire m_axis_main_tready,

	// S_AXIS_MAIN : AXI4-Stream slave interface (from TEMAC of main iface)

	input wire s_axis_main_clk,

	input wire [7:0] s_axis_main_tdata,
	input wire s_axis_main_tkeep,
	input wire s_axis_main_tlast,
	input wire s_axis_main_tvalid,

	// M_AXIS_LOOP : AXI4-Stream master interface (to TEMAC of loopback iface)

	output wire [7:0] m_axis_loop_tdata,
	output wire m_axis_loop_tkeep,
	output wire m_axis_loop_tlast,
	output wire m_axis_loop_tvalid,
	input wire m_axis_loop_tready,

	// S_AXIS_LOOP : AXI4-Stream slave interface (from TEMAC of loopback iface)

	input wire s_axis_loop_clk,

	input wire [7:0] s_axis_loop_tdata,
	input wire s_axis_loop_tkeep,
	input wire s_axis_loop_tlast,
	input wire s_axis_loop_tvalid,

	// MAIN_RX_STATS : Reception statistics provided by main TEMAC

	input wire [31:0] main_rx_stats_vector,
	input wire main_rx_stats_valid,

	// MAIN_TX_STATS : Transmission statistics provided by main TEMAC

	input wire [31:0] main_tx_stats_vector,
	input wire main_tx_stats_valid,

	// LOOP_RX_STATS : Reception statistics provided by loopback TEMAC

	input wire [27:0] loop_rx_stats_vector,
	input wire loop_rx_stats_valid,

	// LOOP_TX_STATS : Transmission statistics provided by loopback TEMAC

	input wire [31:0] loop_tx_stats_vector,
	input wire loop_tx_stats_valid
);
	eth_measurer #(main_mac, loop_mac, identifier) U0
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
		.m_axis_main_tkeep(m_axis_main_tkeep),
		.m_axis_main_tlast(m_axis_main_tlast),
		.m_axis_main_tvalid(m_axis_main_tvalid),
		.m_axis_main_tready(m_axis_main_tready),

		// S_AXIS_MAIN

		.s_axis_main_clk(s_axis_main_clk),

		.s_axis_main_tdata(s_axis_main_tdata),
		.s_axis_main_tkeep(s_axis_main_tkeep),
		.s_axis_main_tlast(s_axis_main_tlast),
		.s_axis_main_tvalid(s_axis_main_tvalid),
		.s_axis_main_tready(s_axis_main_tready),

		// M_AXIS_LOOP

		.m_axis_loop_tdata(m_axis_loop_tdata),
		.m_axis_loop_tkeep(m_axis_loop_tkeep),
		.m_axis_loop_tlast(m_axis_loop_tlast),
		.m_axis_loop_tvalid(m_axis_loop_tvalid),
		.m_axis_loop_tready(m_axis_loop_tready),

		// S_AXIS_LOOP

		.s_axis_loop_clk(s_axis_loop_clk),

		.s_axis_loop_tdata(s_axis_loop_tdata),
		.s_axis_loop_tkeep(s_axis_loop_tkeep),
		.s_axis_loop_tlast(s_axis_loop_tlast),
		.s_axis_loop_tvalid(s_axis_loop_tvalid),
		.s_axis_loop_tready(s_axis_loop_tready),

		// MAIN_RX_STATS

		.main_rx_stats_vector(main_rx_stats_vector),
		.main_rx_stats_valid(main_rx_stats_valid),

		// MAIN_TX_STATS

		.main_tx_stats_vector(main_tx_stats_vector),
		.main_tx_stats_valid(main_tx_stats_valid),

		// LOOP_RX_STATS

		.loop_rx_stats_vector(loop_rx_stats_vector),
		.loop_rx_stats_valid(loop_rx_stats_valid),

		// LOOP_TX_STATS

		.loop_tx_stats_vector(loop_tx_stats_vector),
		.loop_tx_stats_valid(loop_tx_stats_valid)
	);
endmodule

