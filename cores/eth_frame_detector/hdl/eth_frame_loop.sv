/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop #(parameter C_LOOP_FIFO_SIZE = 2048)
(
	input logic clk,
	input logic rst_n,

	input logic mode,

	// M_AXIS : AXI4-Stream master interface

	input logic m_axis_clk,

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS : AXI4-Stream slave interface

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic [1:0] s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	logic rst_n_m, rst_n_s;
	logic mode_s;

	logic [7:0] m_axis_frame_tdata;
	logic m_axis_frame_tuser;
	logic m_axis_frame_tlast;
	logic m_axis_frame_tvalid;
	logic m_axis_frame_tready;

	logic [31:0] m_axis_csum_tdata;
	logic m_axis_csum_tvalid;
	logic m_axis_csum_tready;

	logic [7:0] s_axis_frame_tdata;
	logic s_axis_frame_tuser;
	logic s_axis_frame_tlast;
	logic s_axis_frame_tvalid;
	logic s_axis_frame_tready;

	logic [31:0] s_axis_csum_tdata;
	logic s_axis_csum_tvalid;
	logic s_axis_csum_tready;

	eth_frame_loop_rx U0
	(
		.clk(s_axis_clk),
		.rst_n(rst_n_s),
		.mode(mode_s),

		.m_axis_frame_tdata(m_axis_frame_tdata),
		.m_axis_frame_tuser(m_axis_frame_tuser),
		.m_axis_frame_tlast(m_axis_frame_tlast),
		.m_axis_frame_tvalid(m_axis_frame_tvalid),
		.m_axis_frame_tready(m_axis_frame_tready),

		.m_axis_csum_tdata(m_axis_csum_tdata),
		.m_axis_csum_tvalid(m_axis_csum_tvalid),
		.m_axis_csum_tready(m_axis_csum_tready),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tuser(s_axis_tuser),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid)
	);

	eth_frame_loop_tx U1
	(
		.clk(m_axis_clk),
		.rst_n(rst_n_m),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		.s_axis_frame_tdata(s_axis_frame_tdata),
		.s_axis_frame_tuser(s_axis_frame_tuser),
		.s_axis_frame_tlast(s_axis_frame_tlast),
		.s_axis_frame_tvalid(s_axis_frame_tvalid),
		.s_axis_frame_tready(s_axis_frame_tready),

		.s_axis_csum_tdata(s_axis_csum_tdata),
		.s_axis_csum_tvalid(s_axis_csum_tvalid),
		.s_axis_csum_tready(s_axis_csum_tready)
	);

	// CDC

	sync_ffs #(2, 2) U2
	(
		.clk_src(clk),
		.clk_dst(s_axis_clk),
		.data_in({mode, rst_n}),
		.data_out({mode_s, rst_n_s})
	);

	sync_ffs #(1, 2) U3
	(
		.clk_src(clk),
		.clk_dst(m_axis_clk),
		.data_in(rst_n),
		.data_out(rst_n_m)
	);

	loop_fifo #(C_LOOP_FIFO_SIZE) U4
	(
		.m_aclk(m_axis_clk),
		.s_aclk(s_axis_clk),
		.s_aresetn(rst_n_s),

		.s_axis_frame_tdata(m_axis_frame_tdata),
		.s_axis_frame_tlast(m_axis_frame_tlast),
		.s_axis_frame_tuser(m_axis_frame_tuser),
		.s_axis_frame_tvalid(m_axis_frame_tvalid),
		.s_axis_frame_tready(m_axis_frame_tready),

		.m_axis_frame_tdata(s_axis_frame_tdata),
		.m_axis_frame_tlast(s_axis_frame_tlast),
		.m_axis_frame_tuser(s_axis_frame_tuser),
		.m_axis_frame_tvalid(s_axis_frame_tvalid),
		.m_axis_frame_tready(s_axis_frame_tready),

		.s_axis_csum_tdata(m_axis_csum_tdata),
		.s_axis_csum_tvalid(m_axis_csum_tvalid),
		.s_axis_csum_tready(m_axis_csum_tready),

		.m_axis_csum_tdata(s_axis_csum_tdata),
		.m_axis_csum_tvalid(s_axis_csum_tvalid),
		.m_axis_csum_tready(s_axis_csum_tready)
	);
endmodule
