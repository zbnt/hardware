/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer #(parameter main_mac, parameter loop_mac, parameter identifier, parameter timeout)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

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

	// MAIN_RX_STATS : Reception statistics provided by main TEMAC

	input logic [27:0] main_rx_stats_vector,
	input logic main_rx_stats_valid,

	// MAIN_TX_STATS : Transmission statistics provided by main TEMAC

	input logic [31:0] main_tx_stats_vector,
	input logic main_tx_stats_valid,

	// LOOP_RX_STATS : Reception statistics provided by loopback TEMAC

	input logic [27:0] loop_rx_stats_vector,
	input logic loop_rx_stats_valid,

	// LOOP_TX_STATS : Transmission statistics provided by loopback TEMAC

	input logic [31:0] loop_tx_stats_vector,
	input logic loop_tx_stats_valid
);
	// axi4_lite registers

	logic [31:0] reg_val[0:36];
	logic [31:0] reg_in[0:36];

	logic [63:0] latency;
	logic [31:0] latency_fifo_len;

	logic [63:0] main_total_tx_bytes, main_total_tx_pings, main_total_tx_good, main_total_tx_bad;
	logic [63:0] main_total_rx_bytes, main_total_rx_pings, main_total_rx_good, main_total_rx_bad;
	logic [63:0] loop_total_tx_bytes, loop_total_tx_pings, loop_total_tx_good, loop_total_tx_bad;
	logic [63:0] loop_total_rx_bytes, loop_total_rx_pings, loop_total_rx_good, loop_total_rx_bad;

	axi4_lite_reg_bank #(37, 12, 37'b11) U0
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

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

	always_comb begin
		reg_in[0] = {reg_val[0][31:16], 8'd0, reg_val[0][7:0]};
		reg_in[1] = reg_val[1];

		reg_in[2] = main_total_tx_bytes[31:0];
		reg_in[3] = main_total_tx_bytes[63:32];

		reg_in[4] = main_total_tx_pings[31:0];
		reg_in[5] = main_total_tx_pings[63:32];

		reg_in[6] = main_total_tx_good[31:0];
		reg_in[7] = main_total_tx_good[63:32];

		reg_in[8] = main_total_tx_bad[31:0];
		reg_in[9] = main_total_tx_bad[63:32];

		reg_in[10] = main_total_rx_bytes[31:0];
		reg_in[11] = main_total_rx_bytes[63:32];

		reg_in[12] = main_total_rx_pings[31:0];
		reg_in[13] = main_total_rx_pings[63:32];

		reg_in[14] = main_total_rx_good[31:0];
		reg_in[15] = main_total_rx_good[63:32];

		reg_in[16] = main_total_rx_bad[31:0];
		reg_in[17] = main_total_rx_bad[63:32];

		reg_in[18] = loop_total_tx_bytes[31:0];
		reg_in[19] = loop_total_tx_bytes[63:32];

		reg_in[20] = loop_total_tx_pings[31:0];
		reg_in[21] = loop_total_tx_pings[63:32];

		reg_in[22] = loop_total_tx_good[31:0];
		reg_in[23] = loop_total_tx_good[63:32];

		reg_in[24] = loop_total_tx_bad[31:0];
		reg_in[25] = loop_total_tx_bad[63:32];

		reg_in[26] = loop_total_rx_bytes[31:0];
		reg_in[27] = loop_total_rx_bytes[63:32];

		reg_in[28] = loop_total_rx_pings[31:0];
		reg_in[29] = loop_total_rx_pings[63:32];

		reg_in[30] = loop_total_rx_good[31:0];
		reg_in[31] = loop_total_rx_good[63:32];

		reg_in[32] = loop_total_rx_bad[31:0];
		reg_in[33] = loop_total_rx_bad[63:32];

		reg_in[34] = latency[31:0];
		reg_in[35] = latency[63:32];

		reg_in[36] = latency_fifo_len;
	end

	// traffic coordinator

	logic main_tx_trigger, main_tx_begin, main_rx_end, main_rx_timeout;
	logic loop_tx_trigger, loop_tx_begin, loop_rx_end, loop_rx_timeout;
	logic [15:0] psize;

	eth_measurer_coord #(timeout) U1
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),
		.enable(reg_val[0][0]),

		.psize_req(reg_val[0][31:16]),
		.delay_time(reg_val[1]),

		.main_rx_end(main_rx_end),
		.loop_rx_end(loop_rx_end),

		.psize(psize),
		.main_tx_trigger(main_tx_trigger),
		.loop_tx_trigger(loop_tx_trigger),
		.main_rx_timeout(main_rx_timeout),
		.loop_rx_timeout(loop_rx_timeout)
	);

	// main eth interface

	logic main_tx_good, main_tx_bad;
	logic main_rx_good, main_rx_bad;
	logic [13:0] main_tx_bytes, main_rx_bytes;

	eth_measurer_tx #(main_mac, identifier) U2
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.trigger(main_tx_trigger),
		.tx_begin(main_tx_begin),

		.padding_size(psize),

		.m_axis_tdata(m_axis_main_tdata),
		.m_axis_tkeep(m_axis_main_tkeep),
		.m_axis_tlast(m_axis_main_tlast),
		.m_axis_tvalid(m_axis_main_tvalid),
		.m_axis_tready(m_axis_main_tready)
	);

	eth_measurer_rx #(loop_mac, identifier) U3
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.clk_rx(s_axis_main_clk),
		.rst_rx(s_axis_main_rst),

		.rx_end(main_rx_end),

		.rx_bytes(main_rx_bytes),
		.rx_good(main_rx_good),
		.rx_bad(main_rx_bad),

		.s_axis_tdata(s_axis_main_tdata),
		.s_axis_tkeep(s_axis_main_tkeep),
		.s_axis_tlast(s_axis_main_tlast),
		.s_axis_tvalid(s_axis_main_tvalid),

		.rx_stats_vector(main_rx_stats_vector),
		.rx_stats_valid(main_rx_stats_valid)
	);

	always_comb begin
		if(s_axi_resetn & main_tx_stats_valid) begin
			main_tx_bytes = main_tx_stats_vector[18:5];
			main_tx_good = main_tx_stats_vector[0];
			main_tx_bad = ~main_tx_stats_vector[0];
		end else begin
			main_tx_bytes = 14'd0;
			main_tx_good = 1'b0;
			main_tx_bad = 1'b0;
		end
	end

	// loopback eth interface

	logic loop_tx_good, loop_tx_bad;
	logic loop_rx_good, loop_rx_bad;
	logic [13:0] loop_tx_bytes, loop_rx_bytes;

	eth_measurer_tx #(loop_mac, identifier) U4
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.trigger(loop_tx_trigger),
		.tx_begin(loop_tx_begin),

		.padding_size(psize),

		.m_axis_tdata(m_axis_loop_tdata),
		.m_axis_tkeep(m_axis_loop_tkeep),
		.m_axis_tlast(m_axis_loop_tlast),
		.m_axis_tvalid(m_axis_loop_tvalid),
		.m_axis_tready(m_axis_loop_tready)
	);

	eth_measurer_rx #(main_mac, identifier) U5
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.clk_rx(s_axis_loop_clk),
		.rst_rx(s_axis_loop_rst),

		.rx_end(loop_rx_end),

		.rx_bytes(loop_rx_bytes),
		.rx_good(loop_rx_good),
		.rx_bad(loop_rx_bad),

		.s_axis_tdata(s_axis_loop_tdata),
		.s_axis_tkeep(s_axis_loop_tkeep),
		.s_axis_tlast(s_axis_loop_tlast),
		.s_axis_tvalid(s_axis_loop_tvalid),

		.rx_stats_vector(loop_rx_stats_vector),
		.rx_stats_valid(loop_rx_stats_valid)
	);

	always_comb begin
		if(s_axi_resetn & loop_tx_stats_valid) begin
			loop_tx_bytes = loop_tx_stats_vector[18:5];
			loop_tx_good = loop_tx_stats_vector[0];
			loop_tx_bad = ~loop_tx_stats_vector[0];
		end else begin
			loop_tx_bytes = 14'd0;
			loop_tx_good = 1'b0;
			loop_tx_bad = 1'b0;
		end
	end

	// statistics collection

	eth_measurer_stats U6
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.tx_begin(main_tx_begin),
		.tx_bytes(main_tx_bytes),
		.tx_good(main_tx_good),
		.tx_bad(main_tx_bad),

		.rx_end(main_rx_end),
		.rx_bytes(main_rx_bytes),
		.rx_good(main_rx_good),
		.rx_bad(main_rx_bad),

		.total_tx_bytes(main_total_tx_bytes),
		.total_tx_pings(main_total_tx_pings),
		.total_tx_good(main_total_tx_good),
		.total_tx_bad(main_total_tx_bad),

		.total_rx_bytes(main_total_rx_bytes),
		.total_rx_pings(main_total_rx_pings),
		.total_rx_good(main_total_rx_good),
		.total_rx_bad(main_total_rx_bad)
	);

	eth_measurer_stats U7
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.tx_begin(loop_tx_begin),
		.tx_bytes(loop_tx_bytes),
		.tx_good(loop_tx_good),
		.tx_bad(loop_tx_bad),

		.rx_end(loop_rx_end),
		.rx_bytes(loop_rx_bytes),
		.rx_good(loop_rx_good),
		.rx_bad(loop_rx_bad),

		.total_tx_bytes(loop_total_tx_bytes),
		.total_tx_pings(loop_total_tx_pings),
		.total_tx_good(loop_total_tx_good),
		.total_tx_bad(loop_total_tx_bad),

		.total_rx_bytes(loop_total_rx_bytes),
		.total_rx_pings(loop_total_rx_pings),
		.total_rx_good(loop_total_rx_good),
		.total_rx_bad(loop_total_rx_bad)
	);

	// latency collection

	eth_measurer_timer U8
	(
		.clk(s_axi_clk),
		.rst(~s_axi_resetn),

		.fifo_read(reg_val[0][8]),
		.fifo_out(latency),
		.fifo_len(latency_fifo_len),

		.main_tx_begin(main_tx_begin),
		.main_rx_end(main_rx_end),
		.main_rx_timeout(main_rx_timeout),

		.loop_tx_begin(loop_tx_begin),
		.loop_rx_end(loop_rx_end),
		.loop_rx_timeout(loop_rx_timeout)
	);
endmodule
