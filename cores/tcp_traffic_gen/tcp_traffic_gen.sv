/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module tcp_traffic_gen
(
	input logic clk,
	input logic rst_n,

	// S_AXI : AXI4-Lite slave interface (configuration)

	input logic [6:0] s_axi_awaddr,
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

	input logic [6:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// M_AXIS_TXD : AXI4-Stream master interface (data)

	output logic [31:0] m_axis_txd_tdata,
	output logic [3:0] m_axis_txd_tkeep,
	output logic m_axis_txd_tlast,
	output logic m_axis_txd_tvalid,
	input logic m_axis_txd_tready,

	// M_AXIS_TXC : AXI4-Stream master interface (control)

	output logic [31:0] m_axis_txc_tdata,
	output logic [3:0] m_axis_txc_tkeep,
	output logic m_axis_txc_tlast,
	output logic m_axis_txc_tvalid,
	input logic m_axis_txc_tready
);
	/*
		Registers:

			0     : Config register
			1     : Length and delay
			2-4   : MAC addresses
			5     : Identification, flags, TTL
			6     : Source IP
			7     : Destination IP
			8     : Ports
			9     : Sequence number
			10    : Acknowledgement number
			11    : Flags, window size
			12    : Urgent pointer
			13-23 : Options
	*/

	logic [31:0] reg_val[0:23];

	logic [31:0] cfg;
	logic [3:0] nopts;
	logic [15:0] data_len, eth_length;
	logic [3:0] tcp_len;
	logic [15:0] wtime;

	logic [31:0] frame_headers[0:13];

	always_comb begin
		cfg = reg_val[0];
		nopts = reg_val[0][11:8];
		data_len = reg_val[1][15:0];
		wtime = reg_val[1][31:16];
		eth_length = data_len + 16'd20 + 16'd20 + {8'd0, nopts, 2'd0};
		tcp_len = 4'd5 + nopts;

		frame_headers[0] = reg_val[2];
		frame_headers[1] = reg_val[3];
		frame_headers[2] = reg_val[4];
		frame_headers[3] = {8'h00, 8'h45, 16'h0080};
		frame_headers[4] = {reg_val[5][15:0], eth_length[7:0], eth_length[15:8]};
		frame_headers[5] = {8'h06, reg_val[5][31:24], 14'd0, reg_val[5][17:16]};
		frame_headers[6] = {reg_val[6][15:0], 16'd0};
		frame_headers[7] = {reg_val[7][15:0], reg_val[6][31:16]};
		frame_headers[8] = {reg_val[8][7:0], reg_val[8][15:8], reg_val[7][15:0]};
		frame_headers[9] = {reg_val[9][23:16], reg_val[9][31:24], reg_val[8][23:16], reg_val[8][31:24]};
		frame_headers[10] = {reg_val[10][23:16], reg_val[10][31:24], reg_val[9][7:0], reg_val[9][15:8]};
		frame_headers[11] = {reg_val[11][8:0], 3'd0, tcp_len, reg_val[10][7:0], reg_val[10][15:8]};
		frame_headers[12] = {16'd0, reg_val[11][23:16], reg_val[11][31:24]};
		frame_headers[13] = {16'd0, reg_val[12][7:0], reg_val[12][15:8]};
	end

	axi4_lite_reg_bank #(24, 7, {24{1'b1}}) U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.reg_val(reg_val),
		.reg_in(reg_val),

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

	tcp_traffic_gen_tx U1
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(cfg[0]),

		.frame_headers(frame_headers),
		.ip_options(reg_val[13:23]),
		.num_options(nopts),
		.data_len(data_len),
		.word_cycles(wtime),

		.m_axis_txd_tdata(m_axis_txd_tdata),
		.m_axis_txd_tkeep(m_axis_txd_tkeep),
		.m_axis_txd_tlast(m_axis_txd_tlast),
		.m_axis_txd_tvalid(m_axis_txd_tvalid),
		.m_axis_txd_tready(m_axis_txd_tready),

		.m_axis_txc_tdata(m_axis_txc_tdata),
		.m_axis_txc_tkeep(m_axis_txc_tkeep),
		.m_axis_txc_tlast(m_axis_txc_tlast),
		.m_axis_txc_tvalid(m_axis_txc_tvalid),
		.m_axis_txc_tready(m_axis_txc_tready)
	);
endmodule

