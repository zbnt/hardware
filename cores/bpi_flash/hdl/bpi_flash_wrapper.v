/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_w
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728,

	parameter C_INTERNAL_IOBUF = 1,

	parameter C_ADDR_TO_CEL_TIME = 3,
	parameter C_OEL_TO_OEH_TIME = 6,
	parameter C_WEL_TO_DQ_TIME = 1,
	parameter C_DQ_TO_WEH_TIME = 6,
	parameter C_OEH_TO_DONE_TIME = 5
)
(
	input wire clk,
	input wire rst_n,

	// S_AXI

	input wire [$clog2(C_MEM_SIZE)-1:0] s_axi_awaddr,
	input wire [2:0] s_axi_awprot,
	input wire s_axi_awvalid,
	output wire s_axi_awready,

	input wire [C_AXI_WIDTH-1:0] s_axi_wdata,
	input wire [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input wire s_axi_wvalid,
	output wire s_axi_wready,

	output wire [1:0] s_axi_bresp,
	output wire s_axi_bvalid,
	input wire s_axi_bready,

	input wire [$clog2(C_MEM_SIZE)-1:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// BPI

	output wire [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] bpi_a,
	output wire [C_MEM_WIDTH-1:0] bpi_dq_o,
	output wire [C_MEM_WIDTH-1:0] bpi_dq_t,
	input wire [C_MEM_WIDTH-1:0] bpi_dq_i,
	inout wire [C_MEM_WIDTH-1:0] bpi_dq_io,

	output wire bpi_adv,
	output wire bpi_ce_n,
	output wire bpi_oe_n,
	output wire bpi_we_n
);
	wire [C_MEM_WIDTH-1:0] bpi_dq;

	bpi_flash
	#(
		C_AXI_WIDTH,
		C_MEM_WIDTH,
		C_MEM_SIZE,

		C_ADDR_TO_CEL_TIME,
		C_OEL_TO_OEH_TIME,
		C_WEL_TO_DQ_TIME,
		C_DQ_TO_WEH_TIME,
		C_OEH_TO_DONE_TIME
	)
	U0
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

		// BPI

		.bpi_a(bpi_a),
		.bpi_dq_o(bpi_dq_o),
		.bpi_dq_t(bpi_dq_t),
		.bpi_dq_i(bpi_dq),

		.bpi_adv(bpi_adv),
		.bpi_ce_n(bpi_ce_n),
		.bpi_oe_n(bpi_oe_n),
		.bpi_we_n(bpi_we_n)
	);

	if(C_INTERNAL_IOBUF) begin
		for(genvar i = 0; i < C_MEM_WIDTH; i = i + 1) begin
			IOBUF
			(
				.O(bpi_dq[i]),
				.IO(bpi_dq_io[i]),
				.I(bpi_dq_o[i]),
				.T(bpi_dq_t[i])
			);
		end
	end else begin
		assign bpi_dq = bpi_dq_i;
		assign bpi_dq_io = 1'b0;
	end
endmodule
