/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_collector_w #(parameter axi_width = 32, parameter use_timer = 1, parameter enable_fifo = 1)
(
	input wire clk,
	input wire clk_rx,
	input wire rst_n,

	input wire [63:0] current_time,
	input wire time_running,

	// S_AXI : AXI4-Lite slave interface (from PS)

	input wire [11:0] s_axi_awaddr,
	input wire [2:0] s_axi_awprot,
	input wire s_axi_awvalid,
	output wire s_axi_awready,

	input wire [axi_width-1:0] s_axi_wdata,
	input wire [(axi_width/8)-1:0] s_axi_wstrb,
	input wire s_axi_wvalid,
	output wire s_axi_wready,

	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,

	input wire [11:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [axi_width-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// RX_STATS : Reception statistics provided by TEMAC

	input wire [27:0] rx_stats_vector,
	input wire rx_stats_valid,

	// TX_STATS : Transmission statistics provided by TEMAC

	input wire [31:0] tx_stats_vector,
	input wire tx_stats_valid
);
	eth_stats_collector #(axi_width, enable_fifo) U0
	(
		.clk(clk),
		.clk_rx(clk_rx),
		.rst_n(rst_n),

		.current_time(use_timer ? current_time : 64'd0),
		.time_running(~use_timer | time_running),

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

		// RX_STATS

		.rx_stats_vector(rx_stats_vector),
		.rx_stats_valid(rx_stats_valid),

		// TX_STATS

		.tx_stats_vector(tx_stats_vector),
		.tx_stats_valid(tx_stats_valid)
	);
endmodule

