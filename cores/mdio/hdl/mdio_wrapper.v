/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mdio_w #(parameter C_AXI_WIDTH = 32)
(
	input wire clk,
	input wire rst_n,

	// S_AXI

	input wire [10:0] s_axi_awaddr,
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

	input wire [10:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// MDIO

	inout wire mdio,
	output wire mdc
);
	wire mdio_i, mdio_o, mdio_t;

	mdio #(C_AXI_WIDTH) U0
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

		// MDIO

		.mdio_i(mdio_i),
		.mdio_o(mdio_o),
		.mdio_t(mdio_t),

		.mdc(mdc)
	);

	IOBUF U1
	(
		.I(mdio_o),
		.O(mdio_i),
		.T(mdio_t),
		.IO(mdio)
	);
endmodule

