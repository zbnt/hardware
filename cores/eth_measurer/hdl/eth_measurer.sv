/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core eth_measurer: Ethernet Latency Measurer

	This module measures the latency between two ethernet interfaces and stores the results in a FIFO.
	Latency measurement is performed by sending special frames and measuring the time from transmission
	to arrival on the other network interface. The measurement sequence starts with a _ping_ from the
	main interface and is followed by a _pong_ from the loopback interface when it receives the previously
	mentioned _ping_.

	\supports
		\device zynq Production

	\parameters
		\int main_mac   : MAC address for the main interface, the one that sends pings.
		\int loop_mac   : MAC address for the loopback interface, the one that replies to pings with pongs.
		\int identifier : 32 bits magic constant used to identify ping/pong frames.

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite

			\clk   s_axi_clk
			\rst_n s_axi_resetn

		\iface m_axis_main: Transmission stream for the main TEMAC.
			\type AXI4-Stream

			\clk   s_axi_clk
			\rst_n s_axi_resetn

		\iface m_axis_loop: Transmission stream for the loopback TEMAC.
			\type AXI4-Stream

			\clk   s_axi_clk
			\rst_n s_axi_resetn

		\iface s_axis_main: Reception stream for the main TEMAC.
			\type AXI4-Stream

			\clk   s_axis_main_clk
			\rst_n s_axis_main_rst

		\iface s_axis_loop: Reception stream for the loopback TEMAC.
			\type AXI4-Stream

			\clk   s_axis_loop_clk
			\rst_n s_axis_loop_rst

	\memorymap S_AXI_ADDR
		\regsize 32

		\reg LM_CFG: Latency measurer configuration register.
			\access RW

			\field EN     0      Enable latency measurement.
			\field SRST   1      Software reset, active high, must be set back to 0 again manually.

		\reg LM_PADDING: Frame padding amount.
			\access RW

			\field PSIZE  0-15  Number of bytes of padding to add to ping/pong frames, must be at least 38.

		\reg LM_DELAY: Delay between ping-pong sequences.
			\access RW

			\field DELAY  0-31  Number of clock cycles to wait before starting a new ping-pong sequence.

		\reg LM_TIMEOUT: Ping/pong time limit.
			\access RW

			\field TOUT   0-31   Maximum number of clock cycles to wait for ping/pong reception.

		\reg LM_FIFO_OCCUP: FIFO occupancy.
			\access RO

			\field FOCCUP 0-15   Number of entries currently stored in the internal FIFO.

		\reg LM_FIFO_POP: Read values from FIFO.
			\access RW

			\field FPOP   0-31   If set to a value different from 0, read the next set of values from the FIFO and store them in
			                     the registers. If read, always returns 0.

		\reg LM_TIME_L: Measurement time, lower half.
			\access RO

			\field TIMEL  0-31   Time at which the latency measurement ended, lower 32 bits.

		\reg LM_TIME_H: Measurement time, upper half.
			\access RO

			\field TIMEH  0-31   Time at which the latency measurement ended, upper 32 bits.

		\reg LM_PING_LATENCY: Measured ping latency.
			\access RO

			\field PINGL  0-31   Number of clock cycles elapsed between first byte transmission from main interface and last byte
			                     reception on loopback interface.

		\reg LM_PONG_LATENCY: Measured pong latency.
			\access RO

			\field PONGL  0-31   Number of clock cycles elapsed between first byte transmission from loopback interface and last
			                     byte reception on main interface.

		\reg LM_PP_GOOD_L: Ping-pong sequences completed without error, lower half.
			\access RO

			\field PPGL   0-31   Number of ping-pongs completed successfully, lower 32 bits.

		\reg LM_PP_GOOD_H: Ping-pong sequences completed without error, upper half.
			\access RO

			\field PPGH   0-31   Number of ping-pongs completed successfully, upper 32 bits.

		\reg LM_PINGS_LOST_L: Pings not received in time, lower half.
			\access RO

			\field LPINGL 0-31   Number of pings not received under the maximum time, lower 32 bits.

		\reg LM_PINGS_LOST_H: Pings not received in time, upper half.
			\access RO

			\field LPINGH 0-31   Number of pings not received under the maximum time, upper 32 bits.

		\reg LM_PONGS_LOST_L: Pongs not received in time, lower half.
			\access RO

			\field LPONGL 0-31   Number of pongs not received under the maximum time, lower 32 bits.

		\reg LM_PONGS_LOST_H: Pongs not received in time, upper half.
			\access RO

			\field LPINGH 0-31   Number of pongs not received under the maximum time, upper 32 bits.
*/

module eth_measurer #(parameter axi_width, parameter main_mac, parameter loop_mac, parameter identifier)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

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

	// M_AXIS_MAIN : AXI4-Stream master interface (to TEMAC of main iface)

	output logic [7:0] m_axis_main_tdata,
	output logic m_axis_main_tkeep,
	output logic m_axis_main_tlast,
	output logic m_axis_main_tvalid,
	input logic m_axis_main_tready,

	// S_AXIS_MAIN : AXI4-Stream slave interface (from TEMAC of main iface)

	input logic s_axis_main_clk,
	input logic s_axis_main_rst,

	input logic [7:0] s_axis_main_tdata,
	input logic s_axis_main_tkeep,
	input logic s_axis_main_tlast,
	input logic s_axis_main_tvalid,

	// M_AXIS_LOOP : AXI4-Stream master interface (to TEMAC of loopback iface)

	output logic [7:0] m_axis_loop_tdata,
	output logic m_axis_loop_tkeep,
	output logic m_axis_loop_tlast,
	output logic m_axis_loop_tvalid,
	input logic m_axis_loop_tready,

	// S_AXIS_LOOP : AXI4-Stream slave interface (from TEMAC of loopback iface)

	input logic s_axis_loop_clk,
	input logic s_axis_loop_rst,

	input logic [7:0] s_axis_loop_tdata,
	input logic s_axis_loop_tkeep,
	input logic s_axis_loop_tlast,
	input logic s_axis_loop_tvalid,

	// Timer

	input logic [63:0] current_time,
	input logic time_running
);
	// axi4_lite registers

	logic enable, srst, ping_pong_done;
	logic [15:0] padding_req;
	logic [31:0] delay, timeout, ping_time, pong_time;
	logic [63:0] ping_pongs_good, pings_lost, pongs_lost;

	eth_measurer_axi #(axi_width) U0
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

		.enable(enable),
		.srst(srst),
		.padding(padding_req),
		.delay(delay),
		.timeout(timeout),

		.current_time(current_time),

		.ping_pong_done(ping_pong_done),
		.ping_time(ping_time),
		.pong_time(pong_time),
		.ping_pongs_good(ping_pongs_good),
		.pings_lost(pings_lost),
		.pongs_lost(pongs_lost)
	);

	// traffic coordinator

	logic main_tx_trigger, loop_tx_trigger, main_tx_begin, loop_tx_begin;
	logic [63:0] ping_id, main_rx_ping_id, loop_rx_ping_id;
	logic [15:0] psize;

	eth_measurer_coord U1
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn | srst),
		.enable(enable & time_running),

		.psize_req(padding_req),
		.delay_time(delay),
		.timeout(timeout),

		.psize(psize),

		.ping_id(ping_id),
		.main_rx_ping_id(main_rx_ping_id),
		.loop_rx_ping_id(loop_rx_ping_id),

		.main_tx_trigger(main_tx_trigger),
		.loop_tx_trigger(loop_tx_trigger),
		.main_tx_begin(main_tx_begin),
		.loop_tx_begin(loop_tx_begin),

		.done(ping_pong_done),
		.ping_time(ping_time),
		.pong_time(pong_time),
		.ping_pongs_good(ping_pongs_good),
		.pings_lost(pings_lost),
		.pongs_lost(pongs_lost)
	);

	// main eth interface

	eth_measurer_tx #(main_mac, identifier) U2
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.trigger(main_tx_trigger),
		.tx_begin(main_tx_begin),

		.padding_size(psize),
		.ping_id(ping_id),

		.m_axis_tdata(m_axis_main_tdata),
		.m_axis_tkeep(m_axis_main_tkeep),
		.m_axis_tlast(m_axis_main_tlast),
		.m_axis_tvalid(m_axis_main_tvalid),
		.m_axis_tready(m_axis_main_tready)
	);

	eth_measurer_rx #(loop_mac, identifier) U3
	(
		.clk(s_axi_clk),
		.clk_rx(s_axis_main_clk),
		.rst_rx(s_axis_main_rst),

		.ping_id(main_rx_ping_id),

		.s_axis_tdata(s_axis_main_tdata),
		.s_axis_tkeep(s_axis_main_tkeep),
		.s_axis_tlast(s_axis_main_tlast),
		.s_axis_tvalid(s_axis_main_tvalid)
	);

	// loopback eth interface

	eth_measurer_tx #(loop_mac, identifier) U4
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.trigger(loop_tx_trigger),
		.tx_begin(loop_tx_begin),

		.padding_size(psize),
		.ping_id(ping_id),

		.m_axis_tdata(m_axis_loop_tdata),
		.m_axis_tkeep(m_axis_loop_tkeep),
		.m_axis_tlast(m_axis_loop_tlast),
		.m_axis_tvalid(m_axis_loop_tvalid),
		.m_axis_tready(m_axis_loop_tready)
	);

	eth_measurer_rx #(main_mac, identifier) U5
	(
		.clk(s_axi_clk),
		.clk_rx(s_axis_loop_clk),
		.rst_rx(s_axis_loop_rst),

		.ping_id(loop_rx_ping_id),

		.s_axis_tdata(s_axis_loop_tdata),
		.s_axis_tkeep(s_axis_loop_tkeep),
		.s_axis_tlast(s_axis_loop_tlast),
		.s_axis_tvalid(s_axis_loop_tvalid)
	);
endmodule
