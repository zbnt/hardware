`timescale 1ns / 1ps

module axi4_lite_slave_rw #(parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	output logic write_req,
	output logic [addr_width-1:0] write_addr,
	output logic [31:0] write_value,
	output logic [3:0] write_mask,

	input logic write_ready,
	input logic write_response,

	output logic read_req,
	output logic [addr_width-1:0] read_addr,

	input logic read_ready,
	input logic read_response,
	input logic [31:0] read_value,

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
	axi4_lite_slave_read #(addr_width) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(read_req),
		.read_addr(read_addr),

		.read_ready(read_ready),
		.read_response(read_response),
		.read_value(read_value),

		.s_axi_araddr(s_axi_araddr),
		.s_axi_arprot(s_axi_arprot),
		.s_axi_arvalid(s_axi_arvalid),
		.s_axi_arready(s_axi_arready),

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rready(s_axi_rready)
	);

	axi4_lite_slave_write #(addr_width) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.write_req(write_req),
		.write_addr(write_addr),
		.write_value(write_value),
		.write_mask(write_mask),

		.write_ready(write_ready),
		.write_response(write_response),

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
