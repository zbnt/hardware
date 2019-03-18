`timescale 1ns / 1ps

module axi4_lite_reg_bank #(parameter num_regs = 2, parameter addr_width = 7, parameter allow_write = {num_regs{1'b1}})
(
	input logic clk,
	input logic rst_n,

	output logic [31:0] reg_val[0:num_regs-1],
	input logic [31:0] reg_in[0:num_regs-1],

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
	logic [addr_width-1:0] reg_write_idx;
	logic [31:0] reg_write_value;
	logic reg_write_enable;

	axi4_lite_slave #(num_regs, addr_width) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.reg_vals(reg_val),
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

	register_bank #(num_regs, addr_width, allow_write) U1
	(
		.clk(clk),
		.write_enable(reg_write_enable),
		.write_index(reg_write_idx),
		.write_value(reg_write_value),
		.reg_in(reg_in),
		.reg_val(reg_val)
	);
endmodule

