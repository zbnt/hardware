/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	eth_stats_collector: Ethernet Statistics Collector

	This module collects ethernet traffic statistics using the AXI4-Stream interfaces provided by the MAC. If provided with a reference
	timer, it can keep track of the times at which the values changed, and optionally store these values in a FIFO, allowing them to be
	read from the PS without losing intermediate states as long as the FIFO doesn't overflow.
*/

module eth_stats_collector #(parameter C_AXI_WIDTH = 32, parameter C_ENABLE_FIFO = 1, parameter C_SHARED_TX_CLK = 1, parameter C_FIFO_SIZE = 1024)
(
	input logic clk,
	input logic clk_tx,
	input logic clk_rx,
	input logic rst_n,

	input logic [63:0] current_time,
	input logic time_running,

	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic [11:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// AXIS_TX

	input logic axis_tx_tready,
	input logic axis_tx_tvalid,
	input logic axis_tx_tlast,

	// AXIS_RX

	input logic axis_rx_tvalid,
	input logic axis_rx_tlast,
	input logic axis_rx_tuser
);
	// axi4_lite registers

	logic enable, srst;
	logic [63:0] tx_bytes, tx_good, tx_bad, rx_bytes, rx_good, rx_bad;
	logic [5:0] stats_id;

	eth_stats_collector_axi #(C_AXI_WIDTH, C_ENABLE_FIFO, C_FIFO_SIZE) U0
	(
		.clk(clk),
		.rst_n(rst_n),

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

		.enable(enable),
		.srst(srst),

		.current_time(current_time),
		.stats_id(stats_id),
		.tx_bytes(tx_bytes),
		.tx_good(tx_good),
		.tx_bad(tx_bad),
		.rx_bytes(rx_bytes),
		.rx_good(rx_good),
		.rx_bad(rx_bad)
	);

	// TX statistics, CDC needed only if C_SHARED_TX_CLK == 0

	logic enable_tx, tx_frame_good, tx_valid;
	logic [1:0] rst_tx_n;
	logic [2:0] tx_stats_id;
	logic [16:0] tx_frame_length;
	logic [63:0] tx_bytes_cdc, tx_good_cdc, tx_bad_cdc;

	eth_stats_counter_tx U2
	(
		.clk(clk_tx),
		.rst_n(rst_tx_n[1]),

		.axis_tx_tready(axis_tx_tready),
		.axis_tx_tvalid(axis_tx_tvalid),
		.axis_tx_tlast(axis_tx_tlast),

		.frame_bytes(tx_frame_length),
		.frame_good(tx_frame_good),
		.valid(tx_valid)
	);

	eth_stats_adder U3
	(
		.clk(clk_tx),
		.rst_n(rst_tx_n[0]),
		.enable(enable_tx),

		.valid(tx_valid),
		.frame_length(tx_frame_length),
		.frame_good(tx_frame_good),

		.total_bytes(tx_bytes_cdc),
		.total_good(tx_good_cdc),
		.total_bad(tx_bad_cdc),
		.stats_id(tx_stats_id)
	);

	if(C_SHARED_TX_CLK) begin
		always_ff @(posedge clk) begin
			if(~rst_n | srst) begin
				enable_tx <= 1'b0;
			end else begin
				enable_tx <= enable & time_running;
			end
		end

		always_comb begin
			rst_tx_n = {rst_n, rst_n & ~srst};

			stats_id[2:0] = tx_stats_id;
			tx_bytes = tx_bytes_cdc;
			tx_good = tx_good_cdc;
			tx_bad = tx_bad_cdc;
		end
	end else begin
		bus_cdc #(195, 2)
		(
			.clk_src(clk_tx),
			.clk_dst(clk),
			.data_in({tx_stats_id, tx_bytes_cdc, tx_good_cdc, tx_bad_cdc}),
			.data_out({stats_id[2:0], tx_bytes, tx_good, tx_bad})
		);

		sync_ffs #(3, 2)
		(
			.clk_src(clk),
			.clk_dst(clk_tx),
			.data_in({rst_n, rst_n & ~srst, enable & time_running}),
			.data_out({rst_tx_n, enable_tx})
		);
	end

	// RX statistics, these signals come from another clock domain, so CDC is needed

	logic enable_rx, rx_frame_good, rx_valid;
	logic [1:0] rst_rx_n;
	logic [2:0] rx_stats_id;
	logic [16:0] rx_frame_length;
	logic [63:0] rx_bytes_cdc, rx_good_cdc, rx_bad_cdc;

	eth_stats_counter_rx U4
	(
		.clk(clk_rx),
		.rst_n(rst_rx_n[1]),

		.axis_rx_tvalid(axis_rx_tvalid),
		.axis_rx_tlast(axis_rx_tlast),
		.axis_rx_tuser(axis_rx_tuser),

		.frame_bytes(rx_frame_length),
		.frame_good(rx_frame_good),
		.valid(rx_valid)
	);

	eth_stats_adder U5
	(
		.clk(clk_rx),
		.rst_n(rst_rx_n[0]),
		.enable(enable_rx),

		.valid(rx_valid),
		.frame_length(rx_frame_length),
		.frame_good(rx_frame_good),

		.total_bytes(rx_bytes_cdc),
		.total_good(rx_good_cdc),
		.total_bad(rx_bad_cdc),
		.stats_id(rx_stats_id)
	);

	bus_cdc #(195, 2) U6
	(
		.clk_src(clk_rx),
		.clk_dst(clk),
		.data_in({rx_stats_id, rx_bytes_cdc, rx_good_cdc, rx_bad_cdc}),
		.data_out({stats_id[5:3], rx_bytes, rx_good, rx_bad})
	);

	sync_ffs #(3, 2) U7
	(
		.clk_src(clk),
		.clk_dst(clk_rx),
		.data_in({rst_n, rst_n & ~srst, enable & time_running}),
		.data_out({rst_rx_n, enable_rx})
	);
endmodule
