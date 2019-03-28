
module axi4_lite_slave_write #(parameter addr_width = 7)
(
	input logic clk,
	input logic rst_n,

	output logic write_req,
	output logic [addr_width-1:0] write_addr,
	output logic [31:0] write_value,
	output logic [3:0] write_mask,

	input logic write_ready,
	input logic write_response,

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
	input logic s_axi_bready
);
	// Receive write address

	logic awready_next;
	logic [addr_width-1:0] write_addr_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			s_axi_awready <= 1'b0;
			write_addr <= '0;
		end else begin
			s_axi_awready <= awready_next;
			write_addr <= write_addr_next;
		end
	end

	always_comb begin
		if(rst_n & s_axi_awvalid & s_axi_awready) begin
			awready_next = 1'b0;
			write_addr_next = s_axi_awaddr;
		end else if(rst_n | (s_axi_bready & s_axi_bvalid)) begin
			awready_next = 1'b1;
			write_addr_next = write_addr;
		end else begin
			awready_next = s_axi_awready;
			write_addr_next = write_addr;
		end
	end

	// Receive write value

	logic wready_next;
	logic [31:0] write_value_next;
	logic [3:0] write_mask_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			s_axi_wready <= 1'b0;
			write_value <= 32'd0;
			write_mask <= 4'd0;
		end else begin
			s_axi_wready <= wready_next;
			write_value <= write_value_next;
			write_mask <= write_mask_next;
		end
	end

	always_comb begin
		if(rst_n & s_axi_wvalid & s_axi_wready) begin
			wready_next = 1'b0;
			write_value_next = s_axi_wdata;
			write_mask_next = s_axi_wstrb;
		end else if(rst_n | (s_axi_bready & s_axi_bvalid)) begin
			wready_next = 1'b1;
			write_value_next = write_value;
			write_mask_next = write_mask;
		end else begin
			wready_next = s_axi_wready;
			write_value_next = write_value;
			write_mask_next = write_mask;
		end
	end

	// Send response

	logic bvalid_next;
	logic [1:0] bresp_next;

	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			s_axi_bvalid <= 1'b0;
			s_axi_bresp <= 2'd0;
		end else begin
			s_axi_bvalid <= bvalid_next;
			s_axi_bresp <= bresp_next;
		end
	end

	always_comb begin
		write_req = rst_n & (~s_axi_awready | ~awready_next) & (~s_axi_wready | ~wready_next);

		if(write_ready & write_req & ~s_axi_bvalid) begin
			bvalid_next = 1'b1;
			bresp_next = {~write_response, 1'b0};
		end else if(rst_n | (s_axi_bready & s_axi_bvalid)) begin
			bvalid_next = 1'b0;
			bresp_next = 2'd0;
		end else begin
			bvalid_next = s_axi_bvalid;
			bresp_next = s_axi_bready;
		end
	end
endmodule
