/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core simple_timer: Simple AXI timer

	This module implements a simple 64 bits timer that can be read and configured using an AXI4-Lite interface.

	\supports
		\device zynq Production

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite

			\clk   clk
			\rst_n rst_n

	\memorymap S_AXI_ADDR
		\regsize 32

		\reg ST_CFG: Timer configuration register.
			\access RW

			\field EN     0      Enable.
			\field SRST   1      Software reset, active high, must be set back to 0 again manually.

		\reg ST_STATUS: Timer status register.
			\access RO

			\field BUSY   0      Set to 1 while the timer is counting, set to 0 otherwise.

		\reg ST_LIMIT_L: Counting limit, lower half.
			\access RO

			\field LIML   0-31   Maximum value, lower 32 bits. The timer will not count past this value.

		\reg ST_LIMIT_H: Counting limit, upper half.
			\access RO

			\field LIMH   0-31   Maximum value, upper 32 bits. The timer will not count past this value/

		\reg ST_COUNT_L: Current count value, lower half.
			\access RO

			\field CNTL   0-31   Current count stored in the timer, lower 32 bits.

		\reg ST_COUNT_H: Current count value, upper half.
			\access RO

			\field CNTH   0-31   Current count stored in the timer, upper 32 bits.
*/

module simple_timer
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
	input logic s_axi_rready
);
	// axi4_lite registers

	logic [31:0] reg_val[0:5];
	logic [31:0] reg_in[0:5];

	logic enable, srst;
	logic [63:0] max_count;

	axi4_lite_reg_bank #(6, 12, 6'b1101) U0
	(
		.clk(clk),
		.rst_n(rst_n),

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
		enable = reg_val[0][0];
		srst = reg_val[0][1];
		max_count = {reg_val[3], reg_val[2]};

		time_running = (enable & ~srst & rst_n) && (current_time < max_count);

		reg_in[0] = ~srst ? reg_val[0] : 32'b10;
		reg_in[1] = {31'd0, time_running};
		reg_in[2] = ~srst ? reg_val[2] : 32'd0;
		reg_in[3] = ~srst ? reg_val[3] : 32'd0;
		reg_in[4] = current_time[31:0];
		reg_in[5] = current_time[63:32];
	end

	// counter

	counter_big #(64) U1
	(
		.clk(clk),
		.rst(~rst_n | srst),

		.enable(time_running),

		.count(current_time)
	);
endmodule
