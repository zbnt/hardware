/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_collector_w #(parameter C_AXI_WIDTH = 32, parameter C_USE_TIMER = 1, parameter C_ENABLE_FIFO = 1, parameter C_SHARED_TX_CLK = 1)
(
	input wire clk,
	input wire clk_tx,
	input wire clk_rx,
	input wire rst_n,

	input wire [63:0] current_time,
	input wire time_running,

	// S_AXI : AXI4-Lite slave interface (from PS)

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

	// AXIS_TX

	input wire axis_tx_tready,
	input wire axis_tx_tvalid,
	input wire axis_tx_tlast,

	// AXIS_RX

	input wire axis_rx_tvalid,
	input wire axis_rx_tlast,
	input wire axis_rx_tuser
);
	eth_stats_collector #(C_AXI_WIDTH, C_ENABLE_FIFO, C_SHARED_TX_CLK) U0
	(
		.clk(clk),
		.clk_tx(C_SHARED_TX_CLK ? clk : clk_tx),
		.clk_rx(clk_rx),
		.rst_n(rst_n),

		.current_time(C_USE_TIMER ? current_time : 64'd0),
		.time_running(~|C_USE_TIMER | time_running),

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

		// AXIS_TX

		.axis_tx_tready(axis_tx_tready),
		.axis_tx_tvalid(axis_tx_tvalid),
		.axis_tx_tlast(axis_tx_tlast),

		// AXIS_RX

		.axis_rx_tvalid(axis_rx_tvalid),
		.axis_rx_tlast(axis_rx_tlast),
		.axis_rx_tuser(axis_rx_tuser)
	);
endmodule

