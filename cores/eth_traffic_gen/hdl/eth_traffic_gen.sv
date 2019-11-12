/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	eth_traffic_gen: Ethernet Traffic Generator

	This core generates a stream of ethernet frames by combining headers stored in DRAM and pseudo-random data
	obtained from a linear-feedback shift register. The core provides an AXI4-Lite interface that allows the
	user to adjust the contents of the frame headers, the size of the pseudo-random payload and the idle time
	between generated frames.
*/

module eth_traffic_gen #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst_n,

	input logic ext_enable,

	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic [12:0] s_axi_awaddr,
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

	input logic [12:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [axi_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// M_AXIS : AXI4-Stream master interface (to TEMAC)

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic glob_enable;
	logic tx_enable;
	logic tx_busy;
	logic [1:0] tx_state;
	logic [15:0] frame_size;
	logic [31:0] frame_delay;

	logic use_burst, burst_enable;
	logic [15:0] burst_on_time, burst_off_time;

	logic lfsr_seed_req;
	logic [7:0] lfsr_seed_val;

	logic [10-$clog2(axi_width/8):0] mem_frame_a_addr, mem_frame_b_addr;
	logic [axi_width-1:0] mem_frame_a_wdata, mem_frame_a_rdata;
	logic [axi_width-1:0] mem_frame_b_rdata;
	logic [(axi_width/8)-1:0] mem_frame_a_we;

	logic [7-$clog2(axi_width/8):0] mem_pattern_a_addr, mem_pattern_b_addr;
	logic [axi_width-1:0] mem_pattern_a_wdata, mem_pattern_a_rdata;
	logic [axi_width-1:0] mem_pattern_b_rdata;
	logic [(axi_width/8)-1:0] mem_pattern_a_we;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			glob_enable <= 1'b0;
		end else begin
			glob_enable <= tx_enable & ext_enable & (burst_enable | ~use_burst);
		end
	end

	eth_traffic_gen_axi #(axi_width) U0
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

		.mem_frame_addr(mem_frame_a_addr),
		.mem_frame_wdata(mem_frame_a_wdata),
		.mem_frame_we(mem_frame_a_we),
		.mem_frame_rdata(mem_frame_a_rdata),

		.mem_pattern_addr(mem_pattern_a_addr),
		.mem_pattern_wdata(mem_pattern_a_wdata),
		.mem_pattern_we(mem_pattern_a_we),
		.mem_pattern_rdata(mem_pattern_a_rdata),

		.tx_enable(tx_enable),

		.tx_state(tx_state),
		.tx_ptr({mem_frame_b_addr, {($clog2(axi_width/8)){1'b0}}}),

		.frame_size(frame_size),
		.frame_delay(frame_delay),

		.use_burst(use_burst),
		.burst_on_time(burst_on_time),
		.burst_off_time(burst_off_time),

		.lfsr_seed_req(lfsr_seed_req),
		.lfsr_seed_val(lfsr_seed_val)
	);

	eth_traffic_gen_axis #(axi_width) U1
	(
		.clk(clk),
		.rst(~rst_n),

		.tx_state(tx_state),

		.enable(glob_enable),
		.frame_size(frame_size),
		.frame_delay(frame_delay),

		.lfsr_seed_req(lfsr_seed_req),
		.lfsr_seed_val(lfsr_seed_val),

		.mem_frame_addr(mem_frame_b_addr),
		.mem_frame_rdata(mem_frame_b_rdata),

		.mem_pattern_addr(mem_pattern_b_addr),
		.mem_pattern_rdata(mem_pattern_b_rdata),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	frame_dram #(axi_width) U2
	(
		.clk(clk),

		.a(mem_frame_a_addr),
		.d(mem_frame_a_wdata),
		.spo(mem_frame_a_rdata),
		.we(mem_frame_a_we),

		.dpra(mem_frame_b_addr),
		.dpo(mem_frame_b_rdata)
	);

	pattern_dram #(axi_width) U3
	(
		.clk(clk),

		.a(mem_pattern_a_addr),
		.d(mem_pattern_a_wdata),
		.spo(mem_pattern_a_rdata),
		.we(mem_pattern_a_we),

		.dpra(mem_pattern_b_addr),
		.dpo(mem_pattern_b_rdata)
	);

	eth_traffic_gen_burst U4
	(
		.clk(clk),
		.rst_n(rst_n),

		.use_burst(use_burst),
		.burst_on_time(burst_on_time),
		.burst_off_time(burst_off_time),

		.burst_enable(burst_enable)
	);
endmodule

