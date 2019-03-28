`timescale 1ns / 1ps

module axi4_lite_slave_read #(parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	output logic read_req,
	output logic [addr_width-1:0] read_addr,

	input logic read_ready,
	input logic read_response,
	input logic [31:0] read_value,

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	// Receive read address

	logic arready_next;
	logic [addr_width-1:0] read_addr_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			s_axi_arready <= 1'b0;
			read_addr <= '0;
		end else begin
			s_axi_arready <= arready_next;
			read_addr <= read_addr_next;
		end
	end

	always_comb begin
		if(rst_n & s_axi_arvalid) begin
			arready_next = 1'b0;
			read_addr_next = s_axi_araddr;
		end else if(rst_n | (s_axi_rready & s_axi_rvalid)) begin
			arready_next = 1'b1;
			read_addr_next = read_addr;
		end else begin
			arready_next = s_axi_arready;
			read_addr_next = read_addr;
		end
	end

	// Send response

	logic rvalid_next;
	logic [31:0] rdata_next;
	logic [1:0] rresp_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			s_axi_rvalid <= 1'b0;
			s_axi_rdata <= 32'd0;
			s_axi_rresp <= 2'd0;
		end else begin
			s_axi_rvalid <= rvalid_next;
			s_axi_rdata <= rdata_next;
			s_axi_rresp <= rresp_next;
		end
	end

	always_comb begin
		read_req = rst_n & (~s_axi_arready | ~arready_next);

		if(read_ready & read_req & ~s_axi_rvalid) begin
			rvalid_next = 1'b1;
			rdata_next = read_value;
			rresp_next = {~read_response, 1'b0};
		end else if(rst_n | (s_axi_rready & s_axi_rvalid)) begin
			rvalid_next = 1'b0;
			rdata_next = 32'd0;
			rresp_next = 2'd0;
		end else begin
			rvalid_next = s_axi_rvalid;
			rdata_next = s_axi_rdata;
			rresp_next = s_axi_rresp;
		end
	end
endmodule
