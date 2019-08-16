/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core eth_stats_collector: Ethernet Statistics Collector

	This module collects ethernet traffic statistics using the AXI4-Stream interfaces provided by the MAC. If provided with a reference
	timer, it can keep track of the times at which the values changed, and optionally store these values in a FIFO, allowing them to be
	read from the PS without losing intermediate states as long as the FIFO doesn't overflow.

	\parameters
		\bool use_timer   : Enables the use of a reference 64 bit timer for keeping track of time. If set to 1, statistics will be
		                    collected only if the timer is running.

		\bool enable_fifo : Enables the use of a FIFO for storing statistics.

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite

			\clk   clk
			\rst_n rst_n

		\iface AXIS_TX: Transmission stream.
			\type AXI4-Stream

			\clk   clk
			\rst_n rst_n

		\iface AXIS_RX: Reception stream.
			\type AXI4-Stream

			\clk   clk_rx
			\rst_n rst_n

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
			\field EFIFO  3      Enables the use of a FIFO for storing statistics, writing to this bit has no effect if the core
						   was generated with enable_fifo equal to 0.

		\reg SC_FIFO_OCCUP: FIFO occupancy.
			\access RO

			\field FOCCUP 0-15   Number of entries currently stored in the internal FIFO. If the core was configured without FIFO
			                     support, reads to this register will always return 0.

		\reg SC_FIFO_POP: Read values from FIFO.
			\access RW

			\field FPOP   0-31   If set to a value different from 0, read the next set of values from the FIFO and store them in
			                     the registers. If read, always returns 0. This field is ignored if the core was configured with
			                     the FIFO disabled.

		\reg SC_SAMPLING_PERIOD: Sampling period.
			\access RW

			\field STIME  0-31   Number of clock cycles to wait before checking if the statistics have changed again.

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

module eth_stats_collector #(parameter axi_width = 32, parameter enable_fifo = 1)
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

	input logic [axi_width-1:0] s_axi_wdata,
	input logic [(axi_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [axi_width-1:0] s_axi_rdata,
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

	eth_stats_collector_axi #(axi_width, enable_fifo) U0
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

	// TX statistics, no CDC needed here

	logic enable_tx, tx_frame_good, tx_valid;
	logic [15:0] tx_frame_length;

	eth_stats_counter_tx U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.axis_tx_tready(axis_tx_tready),
		.axis_tx_tvalid(axis_tx_tvalid),
		.axis_tx_tlast(axis_tx_tlast),

		.frame_bytes(tx_frame_length),
		.frame_good(tx_frame_good),
		.valid(tx_valid)
	);

	eth_stats_adder U3
	(
		.clk(clk),
		.rst_n(rst_n & ~srst),
		.enable(enable_tx),

		.valid(tx_valid),
		.frame_length(tx_frame_length),
		.frame_good(tx_frame_good),

		.total_bytes(tx_bytes),
		.total_good(tx_good),
		.total_bad(tx_bad),
		.stats_id(stats_id[2:0])
	);

	always_ff @(posedge clk) begin
		if(~rst_n | srst) begin
			enable_tx <= 1'b0;
		end else begin
			enable_tx <= enable & time_running;
		end
	end

	// RX statistics, these signals come from another clock domain, so CDC is needed

	logic enable_rx, rx_frame_good, rx_valid;
	logic [1:0] rst_rx_n;
	logic [2:0] rx_stats_id;
	logic [15:0] rx_frame_length;
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
