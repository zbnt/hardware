/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	simple_timer: Simple AXI timer

	This module implements a simple 64 bits timer that can be read and configured using an AXI4-Lite interface.
*/

module simple_timer #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst_n,

	output logic [63:0] current_time,
	output logic time_running,

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
	input logic s_axi_rready
);
	// axi4_lite registers

	logic enable;
	logic srst;
	logic [63:0] max_count;

	simple_timer_axi #(axi_width) U0
	(
		.clk(clk),
		.rst_n(rst_n),

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

		// Registers

		.enable(enable),
		.srst(srst),

		.running(time_running),

		.max_count(max_count),
		.current_count(current_time)
	);

	// counter

	counter_big #(64) U1
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.enable(time_running),

		.count(current_time)
	);

	always_ff @(posedge clk) begin
		time_running <= (enable & ~srst & rst_n) && (current_time < max_count);
	end
endmodule
