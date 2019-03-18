`timescale 1ns / 1ps

module axi4_lite_slave #(parameter num_regs = 2, parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	input logic [31:0] reg_vals[0:num_regs-1],
	output logic [addr_width-1:0] reg_write_idx,
	output logic [31:0] reg_write_value,
	output logic reg_write_enable,

	input logic [addr_width-1:0] s_axi_awaddr,
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

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	axi4_lite_slave_read #(num_regs, addr_width) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.reg_vals(reg_vals),

		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready)
	);

	axi4_lite_slave_write #(num_regs, addr_width) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.reg_vals(reg_vals),
		.reg_write_enable(reg_write_enable),
		.reg_write_idx(reg_write_idx),
		.reg_write_value(reg_write_value),

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
		.s_axi_bready(s_axi_bready)
	);
endmodule
