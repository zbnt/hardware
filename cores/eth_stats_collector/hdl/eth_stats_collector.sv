/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core eth_stats_collector: Ethernet Statistics Collector

	This module collects ethernet traffic statistics using the vectors provided by Xilinx's TEMAC IP core. If provided with a reference
	timer, it can keep track of the times at which the values changed, and optionally store these values in a FIFO, allowing them to be
	read from the Zynq PS without losing intermediate states as long as the FIFO doesn't overflow.

	\supports
		\device zynq Production

	\parameters
		\bool use_time : Enables the use of a reference 64 bit timer for keeping track of time. If set to 1, statistics will be
		                 collected only if the timer is running.

		\bool use_fifo : Enables the use of a FIFO for storing statistics.

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite

			\clk   clk
			\rst_n rst_n

		\port rx_stats_vector: Reception statistics vector provided by TEMAC.
		\port rx_stats_valid: Valid flag for {rx_stats_vector}.

		\port tx_stats_vector: Transmission statistics vector provided by TEMAC.
		\port tx_stats_valid: Valid flag for {tx_stats_vector}.

	\memorymap S_AXI_ADDR
		\regsize 32

		\reg SC_CFG: Statistics collector configuration register.
			\access RW

			\field EN     0      Enable statistics collection.
			\field SRST   1      Software reset, active high, must be set back to 0 again manually.
			\field HOLD   2      Hold values in the statistics registers. Statistics will continue to be collected, but the value
			                     read from registers will be the ones set at the moment this bit was set to 1. This allows you to
			                     save a snapshot of the statistics without reading values from two or more different states. This
			                     field is ignored if the core was configured with the FIFO enabled.

		\reg SC_FIFO_OCCUP: FIFO occupancy.
			\access RO

			\field FOCCUP 0-15   Number of entries currently stored in the internal FIFO. If the core was configured without FIFO
			                     support, reads to this register will always return 0.

		\reg SC_FIFO_POP: Read values from FIFO.
			\access RW

			\field FPOP   0-31   If set to a value different from 0, read the next set of values from the FIFO and store them in
			                     the registers. If read, always returns 0. This field is ignored if the core was configured with
			                     the FIFO disabled.

		\reg SC_RSVD: Reserved.
			\access RO

		\reg SC_TIME_L: Statistics time, lower half.
			\access RO

			\field TIMEL  0-31   Time of the last statistics change, lower 32 bits.

		\reg SC_TIME_H: Statistics time, upper half.
			\access RO

			\field TIMEH  0-31   Time of the last statistics change, upper 32 bits.

		\reg SC_TX_BYTES_L: Bytes transmitted, lower half.
			\access RO

			\field TXBL   0-31   Number of bytes transmitted, lower 32 bits.

		\reg SC_TX_BYTES_H: Bytes transmitted, upper half.
			\access RO

			\field TXBH   0-31   Number of bytes transmitted, upper 32 bits.

		\reg SC_TX_GOOD_L: Frames transmitted without error, lower half.
			\access RO

			\field TFGL   0-31   Number of frames transmitted successfully, lower 32 bits.

		\reg SC_TX_GOOD_H: Frames transmitted without error, upper half.
			\access RO

			\field TFGH   0-31   Number of frames transmitted successfully, upper 32 bits.

		\reg SC_TX_BAD_L: Frames transmission failures, lower half.
			\access RO

			\field TFBL   0-31   Number of frames not properly transmitted, lower 32 bits.

		\reg SC_TX_BAD_H: Frames transmission failures, upper half.
			\access RO

			\field TFBH   0-31   Number of frames not properly transmitted, upper 32 bits.

		\reg SC_RX_BYTES_L: Bytes received, lower half.
			\access RO

			\field TXBL   0-31   Number of bytes received, lower 32 bits.

		\reg SC_RX_BYTES_H: Bytes received, upper half.
			\access RO

			\field TXBH   0-31   Number of bytes received, upper 32 bits.

		\reg SC_RX_GOOD_L: Frames received without error, lower half.
			\access RO

			\field TFGL   0-31   Number of frames received successfully, lower 32 bits.

		\reg SC_RX_GOOD_H: Frames received without error, upper half.
			\access RO

			\field TFGH   0-31   Number of frames received successfully, upper 32 bits.

		\reg SC_RX_BAD_L: Frames reception failures, lower half.
			\access RO

			\field TFBL   0-31   Number of frames not properly received, lower 32 bits.

		\reg SC_RX_BAD_H: Frames reception failures, upper half.
			\access RO

			\field TFBH   0-31   Number of frames not properly received, upper 32 bits.
*/

module eth_stats_collector #(parameter use_time = 1, parameter use_fifo = 1)
(
	input logic clk,
	input logic clk_rx,
	input logic rst_n,

	input logic [63:0] current_time,
	input logic time_running,

	// S_AXI : AXI4-Lite slave interface (from PS)

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

	// RX_STATS : Reception statistics provided by TEMAC

	input logic [27:0] rx_stats_vector,
	input logic rx_stats_valid,

	// TX_STATS : Transmission statistics provided by TEMAC

	input logic [31:0] tx_stats_vector,
	input logic tx_stats_valid
);
	// axi4_lite registers

	logic enable, srst;
	logic [63:0] tx_bytes, tx_good, tx_bad, rx_bytes, rx_good, rx_bad;

	eth_stats_collector_axi #(use_fifo) U0
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

		.current_time(use_time ? current_time : 64'd0),
		.tx_bytes(tx_bytes),
		.tx_good(tx_good),
		.tx_bad(tx_bad),
		.rx_bytes(rx_bytes),
		.rx_good(rx_good),
		.rx_bad(rx_bad)
	);

	// TX statistics, no CDC needed here

	eth_stats_adder U2
	(
		.clk(clk),
		.rst_n(rst_n & ~srst),
		.enable(enable & (~use_time | time_running)),

		.valid(tx_stats_valid),
		.frame_length(tx_stats_vector[18:5]),
		.frame_good(tx_stats_vector[0]),

		.total_bytes(tx_bytes),
		.total_good(tx_good),
		.total_bad(tx_bad)
	);

	// RX statistics, these signals come from another clock domain, so CDC is needed

	logic rst_rx_n, enable_rx;
	logic [63:0] rx_bytes_cdc, rx_good_cdc, rx_bad_cdc;

	eth_stats_adder U3
	(
		.clk(clk_rx),
		.rst_n(rst_rx_n),
		.enable(enable_rx),

		.valid(rx_stats_valid),
		.frame_length(rx_stats_vector[18:5]),
		.frame_good(rx_stats_vector[0]),

		.total_bytes(rx_bytes_cdc),
		.total_good(rx_good_cdc),
		.total_bad(rx_bad_cdc)
	);

	sync_ffs #(192, 2) U4
	(
		.clk(clk),
		.data_in({rx_bytes_cdc, rx_good_cdc, rx_bad_cdc}),
		.data_out({rx_bytes, rx_good, rx_bad})
	);

	sync_ffs #(2, 2) U5
	(
		.clk(clk_rx),
		.data_in({rst_n & ~srst, enable & (~use_time | time_running)}),
		.data_out({rst_rx_n, enable_rx})
	);
endmodule
