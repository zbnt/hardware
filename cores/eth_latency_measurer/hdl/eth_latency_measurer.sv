/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	eth_latency_measurer: Ethernet Latency Measurer

	This module measures the latency between two ethernet interfaces.	Latency measurement is performed by
	sending ICMP echo frames and measuring the time from transmission to arrival on the other network interface.
	The measurement sequence starts with a "ping" from the main interface and the	loopback interface replies with
	a "pong".
*/

module eth_latency_measurer #(parameter C_AXI_WIDTH = 32, parameter C_AXIS_LOG_ENABLE = 1, parameter C_AXIS_LOG_WIDTH = 64)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

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

	// M_AXIS_MAIN : AXI4-Stream master interface (to TEMAC of main iface)

	output logic [7:0] m_axis_main_tdata,
	output logic m_axis_main_tuser,
	output logic m_axis_main_tlast,
	output logic m_axis_main_tvalid,
	input logic m_axis_main_tready,

	// S_AXIS_MAIN : AXI4-Stream slave interface (from TEMAC of main iface)

	input logic s_axis_main_clk,

	input logic [7:0] s_axis_main_tdata,
	input logic [2:0] s_axis_main_tuser,
	input logic s_axis_main_tlast,
	input logic s_axis_main_tvalid,

	// M_AXIS_LOOP : AXI4-Stream master interface (to TEMAC of loopback iface)

	output logic [7:0] m_axis_loop_tdata,
	output logic m_axis_loop_tuser,
	output logic m_axis_loop_tlast,
	output logic m_axis_loop_tvalid,
	input logic m_axis_loop_tready,

	// S_AXIS_LOOP : AXI4-Stream slave interface (from TEMAC of loopback iface)

	input logic s_axis_loop_clk,

	input logic [7:0] s_axis_loop_tdata,
	input logic [2:0] s_axis_loop_tuser,
	input logic s_axis_loop_tlast,
	input logic s_axis_loop_tvalid,

	// M_AXIS_LOG

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output logic m_axis_log_tlast,
	output logic m_axis_log_tvalid,
	input logic m_axis_log_tready,

	// Timer

	input logic [63:0] current_time,
	input logic time_running
);
	// axi4_lite registers

	logic enable, srst, log_enable, use_broadcast, ping_done;
	logic [15:0] padding_req, log_id;
	logic [47:0] mac_addr_a, mac_addr_b;
	logic [31:0] ip_addr_a, ip_addr_b;
	logic [31:0] delay, timeout, ping_time, pong_time;
	logic [63:0] ping_count, pings_lost, pongs_lost, overflow_count;

	eth_latency_measurer_axi #(C_AXI_WIDTH, C_AXIS_LOG_ENABLE) U0
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
		.log_enable(log_enable),
		.use_broadcast(use_broadcast),
		.log_id(log_id),

		.mac_addr_a(mac_addr_a),
		.mac_addr_b(mac_addr_b),
		.ip_addr_a(ip_addr_a),
		.ip_addr_b(ip_addr_b),

		.padding(padding_req),
		.delay(delay),
		.timeout(timeout),
		.overflow_count(overflow_count),

		.current_time(current_time),

		.ping_count(ping_count),
		.ping_time(ping_time),
		.pong_time(pong_time),
		.pings_lost(pings_lost),
		.pongs_lost(pongs_lost)
	);

	// AXIS log

	eth_latency_measurer_axis_log #(C_AXIS_LOG_ENABLE, C_AXIS_LOG_WIDTH) U1
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		.trigger(ping_done),
		.log_id(log_id),
		.overflow_count(overflow_count),

		.current_time(current_time),
		.ping_count(ping_count),
		.ping_time(ping_time),
		.pong_time(pong_time),
		.pings_lost(pings_lost),
		.pongs_lost(pongs_lost),

		.m_axis_log_tdata(m_axis_log_tdata),
		.m_axis_log_tlast(m_axis_log_tlast),
		.m_axis_log_tvalid(m_axis_log_tvalid),
		.m_axis_log_tready(m_axis_log_tready)
	);

	// traffic coordinator

	logic main_tx_trigger, loop_tx_trigger, main_tx_begin, loop_tx_begin;
	logic [15:0] main_rx_ping_id, loop_rx_ping_id;
	logic [15:0] psize;

	logic [47:0] mac_addr_src_a, mac_addr_dst_a, mac_addr_src_b, mac_addr_dst_b;
	logic [31:0] ip_addr_src_a, ip_addr_dst_a, ip_addr_src_b, ip_addr_dst_b;

	eth_latency_measurer_coord U2
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn | srst),
		.enable(enable & time_running),

		.use_broadcast(use_broadcast),
		.delay_time(delay),
		.timeout(timeout),

		.psize_req(padding_req),
		.mac_addr_src_req(mac_addr_a),
		.mac_addr_dst_req(mac_addr_b),
		.ip_addr_src_req(ip_addr_a),
		.ip_addr_dst_req(ip_addr_b),

		.psize(psize),

		.mac_addr_src_a(mac_addr_src_a),
		.mac_addr_dst_a(mac_addr_dst_a),
		.ip_addr_src_a(ip_addr_src_a),
		.ip_addr_dst_a(ip_addr_dst_a),

		.mac_addr_src_b(mac_addr_src_b),
		.mac_addr_dst_b(mac_addr_dst_b),
		.ip_addr_src_b(ip_addr_src_b),
		.ip_addr_dst_b(ip_addr_dst_b),

		.main_rx_ping_id(main_rx_ping_id),
		.loop_rx_ping_id(loop_rx_ping_id),

		.main_tx_trigger(main_tx_trigger),
		.loop_tx_trigger(loop_tx_trigger),
		.main_tx_begin(main_tx_begin),
		.loop_tx_begin(loop_tx_begin),

		.done(ping_done),
		.ping_count(ping_count),
		.ping_time(ping_time),
		.pong_time(pong_time),
		.pings_lost(pings_lost),
		.pongs_lost(pongs_lost)
	);

	// main eth interface

	eth_latency_measurer_tx #(0) U3
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),
		.trigger(main_tx_trigger),
		.tx_begin(main_tx_begin),

		.mac_addr_src(mac_addr_src_a),
		.ip_addr_src(ip_addr_src_a),

		.mac_addr_dst(mac_addr_dst_a),
		.ip_addr_dst(ip_addr_dst_a),

		.padding_size(psize),
		.frame_id(ping_count[15:0]),
		.log_id(log_id),
		.ping_id(ping_count[15:0]),

		.m_axis_tdata(m_axis_main_tdata),
		.m_axis_tuser(m_axis_main_tuser),
		.m_axis_tlast(m_axis_main_tlast),
		.m_axis_tvalid(m_axis_main_tvalid),
		.m_axis_tready(m_axis_main_tready)
	);

	eth_latency_measurer_rx #(1) U4
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),
		.clk_rx(s_axis_main_clk),

		.mac_addr_src(mac_addr_src_b),
		.ip_addr_src(ip_addr_src_b),

		.mac_addr_dst(mac_addr_dst_b),
		.ip_addr_dst(ip_addr_dst_b),

		.frame_id(ping_count[15:0]),
		.log_id(log_id),
		.ping_id(main_rx_ping_id),

		.s_axis_tdata(s_axis_main_tdata),
		.s_axis_tuser(s_axis_main_tuser),
		.s_axis_tlast(s_axis_main_tlast),
		.s_axis_tvalid(s_axis_main_tvalid)
	);

	// loopback eth interface

	eth_latency_measurer_tx #(1) U5
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),
		.trigger(loop_tx_trigger),
		.tx_begin(loop_tx_begin),

		.mac_addr_src(mac_addr_src_b),
		.ip_addr_src(ip_addr_src_b),

		.mac_addr_dst(mac_addr_dst_b),
		.ip_addr_dst(ip_addr_dst_b),

		.padding_size(psize),
		.frame_id(ping_count[15:0]),
		.log_id(log_id),
		.ping_id(ping_count[15:0]),

		.m_axis_tdata(m_axis_loop_tdata),
		.m_axis_tuser(m_axis_loop_tuser),
		.m_axis_tlast(m_axis_loop_tlast),
		.m_axis_tvalid(m_axis_loop_tvalid),
		.m_axis_tready(m_axis_loop_tready)
	);

	eth_latency_measurer_rx #(0) U6
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),
		.clk_rx(s_axis_loop_clk),

		.mac_addr_src(mac_addr_src_a),
		.ip_addr_src(ip_addr_src_a),

		.mac_addr_dst(mac_addr_dst_a),
		.ip_addr_dst(ip_addr_dst_a),

		.frame_id(ping_count[15:0]),
		.log_id(log_id),
		.ping_id(loop_rx_ping_id),

		.s_axis_tdata(s_axis_loop_tdata),
		.s_axis_tuser(s_axis_loop_tuser),
		.s_axis_tlast(s_axis_loop_tlast),
		.s_axis_tvalid(s_axis_loop_tvalid)
	);
endmodule
