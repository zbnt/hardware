
module axi4_lite_slave_basic #(parameter num_regs = 2, parameter addr_width = 7, parameter data_width = 32)
(
	input logic clk,
	input logic rst_n,

	input logic [data_width-1:0] reg_vals[0:num_regs-1],
	output logic [$clog2(num_regs)-1:0] reg_write_idx,
	output logic [data_width-1:0] reg_write_value,
	output logic reg_write_enable,

	input logic [addr_width-1:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [data_width-1:0] s_axi_wdata,
	input logic [(data_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [addr_width-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [data_width-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready
);
	logic read_req, write_req;
	logic read_response, write_response;
	logic [data_width-1:0] read_value;

	logic [addr_width-1:0] write_addr;

	axi4_lite_slave_read #(addr_width, data_width) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.read_req(read_req),

		.read_ready(1'b1),
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

	axi4_lite_slave_write #(addr_width, data_width) U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.write_req(write_req),
		.write_addr(write_addr),

		.write_ready(1'b1),
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

	always_comb begin
		if(s_axi_araddr[addr_width-1:$clog2(data_width/8)] < num_regs) begin
			read_response = 1'b1;
			read_value = reg_vals[s_axi_araddr[addr_width-1:$clog2(data_width/8)]];
		end else begin
			read_response = 1'b0;
			read_value = '0;
		end
	end

	always_comb begin
		write_response = write_addr[addr_width-1:$clog2(data_width/8)] < num_regs;

		if(write_response & write_req) begin
			reg_write_enable = 1'b1;
			reg_write_idx = write_addr[$clog2(num_regs)+$clog2(data_width/8)-1:$clog2(data_width/8)];

			for(int i = 0; i < data_width; i += 8) begin
				if(s_axi_wstrb[i/8]) begin
					reg_write_value[i+7:i] = s_axi_wdata[i+7:i];
				end else begin
					reg_write_value[i+7:i] = reg_vals[reg_write_idx][i+7:i];
				end
			end
		end else begin
			reg_write_enable = 1'b0;
			reg_write_idx = '0;
			reg_write_value = '0;
		end
	end
endmodule
