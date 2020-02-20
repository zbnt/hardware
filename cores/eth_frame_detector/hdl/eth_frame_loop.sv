/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop
#(
	parameter C_AXI_WIDTH = 32,

	parameter C_AXIS_LOG_ENABLE = 1,
	parameter C_AXIS_LOG_WIDTH = 64,
	parameter C_DIRECTION_ID = 65,

	parameter C_ENABLE_COMPARE = 1,
	parameter C_ENABLE_EDIT = 1,
	parameter C_ENABLE_CHECKSUM = 1,
	parameter C_NUM_SCRIPTS = 4,
	parameter C_MAX_SCRIPT_SIZE = 2048,
	parameter C_LOOP_FIFO_A_SIZE = 2048,
	parameter C_LOOP_FIFO_B_SIZE = 128,
	parameter C_EXTRACT_FIFO_SIZE = 2048,

	parameter C_SHARED_RX_CLK = 0,
	parameter C_SHARED_TX_CLK = 0
)
(
	input logic clk,
	input logic rst_n,
	input logic srst,

	input logic [15:0] log_id,
	input logic [63:0] current_time,
	output logic [63:0] overflow_count,

	input logic log_en,
	input logic [C_NUM_SCRIPTS-1:0] script_en,

	// MEM

	input logic mem_req,
	input logic [$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] mem_addr,
	input logic mem_wenable,
	input logic [C_AXI_WIDTH-1:0] mem_wdata,
	output logic [C_AXI_WIDTH-1:0] mem_rdata,
	output logic mem_ack,

	// M_AXIS_LOG

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output logic m_axis_log_tlast,
	output logic m_axis_log_tvalid,
	input logic m_axis_log_tready,

	// M_AXIS

	input logic m_axis_clk,

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS

	input logic s_axis_clk,

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	// CDC

	logic rst_n_s, srst_s, rst_n_m, log_en_s;
	logic [C_NUM_SCRIPTS-1:0] script_en_s;

	if(~C_SHARED_RX_CLK) begin
		sync_ffs #(C_NUM_SCRIPTS + 3, 2) U0
		(
			.clk_src(clk),
			.clk_dst(s_axis_clk),
			.data_in({script_en, log_en, srst, rst_n}),
			.data_out({script_en_s, log_en_s, srst_s, rst_n_s})
		);
	end else begin
		always_comb begin
			rst_n_s = rst_n;
			log_en_s = log_en;
			script_en_s = script_en;
		end
	end

	if(~C_SHARED_TX_CLK) begin
		sync_ffs #(1, 2) U1
		(
			.clk_src(clk),
			.clk_dst(m_axis_clk),
			.data_in(rst_n),
			.data_out(rst_n_m)
		);
	end else begin
		always_comb begin
			rst_n_m = rst_n;
		end
	end

	// Loop

	logic [7:0] axis_rx2cmp_tdata;
	logic [32*C_NUM_SCRIPTS:0] axis_rx2cmp_tuser;
	logic axis_rx2cmp_tlast, axis_rx2cmp_tvalid;

	eth_frame_loop_rx #(C_NUM_SCRIPTS, C_AXI_WIDTH, C_MAX_SCRIPT_SIZE) U2
	(
		.clk(s_axis_clk),
		.rst_n(rst_n_s),

		// MEM

		.clk_mem(clk),

		.mem_req(mem_req),
		.mem_addr(mem_addr),
		.mem_wenable(mem_wenable),
		.mem_wdata(mem_wdata),
		.mem_rdata(mem_rdata),
		.mem_ack(mem_ack),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tuser(s_axis_tuser),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),

		// M_AXIS

		.m_axis_tdata(axis_rx2cmp_tdata),
		.m_axis_tuser(axis_rx2cmp_tuser),
		.m_axis_tlast(axis_rx2cmp_tlast),
		.m_axis_tvalid(axis_rx2cmp_tvalid)
	);

	logic [7:0] axis_cmp2edit_tdata;
	logic [17*C_NUM_SCRIPTS:0] axis_cmp2edit_tuser;
	logic axis_cmp2edit_tlast, axis_cmp2edit_tvalid;

	if(C_ENABLE_COMPARE && C_NUM_SCRIPTS != 0) begin
		eth_frame_loop_compare #(C_NUM_SCRIPTS) U3
		(
			.clk(s_axis_clk),
			.rst_n(rst_n_s),

			.script_en(script_en_s),

			// S_AXIS

			.s_axis_tdata(axis_rx2cmp_tdata),
			.s_axis_tuser(axis_rx2cmp_tuser),
			.s_axis_tlast(axis_rx2cmp_tlast),
			.s_axis_tvalid(axis_rx2cmp_tvalid),

			// M_AXIS

			.m_axis_tdata(axis_cmp2edit_tdata),
			.m_axis_tuser(axis_cmp2edit_tuser),
			.m_axis_tlast(axis_cmp2edit_tlast),
			.m_axis_tvalid(axis_cmp2edit_tvalid)
		);
	end else begin
		always_comb begin
			axis_cmp2edit_tdata = axis_rx2cmp_tdata;
			axis_cmp2edit_tuser[0] = axis_rx2cmp_tuser[0];
			axis_cmp2edit_tlast = axis_rx2cmp_tlast;
			axis_cmp2edit_tvalid = axis_rx2cmp_tvalid;
		end

		for(genvar i = 0; i < C_NUM_SCRIPTS; ++i) begin
			always_comb begin
				axis_cmp2edit_tuser[17*i+17:17*i+1] = {axis_rx2cmp_tuser[32*i+32:32*i+25], axis_rx2cmp_tuser[32*i+16:32*i+9], script_en_s[i]};
			end
		end
	end

	logic [7:0] axis_edit2csum_tdata;
	logic [9:0] axis_edit2csum_tuser;
	logic axis_edit2csum_tlast, axis_edit2csum_tvalid;

	if(C_ENABLE_EDIT && C_NUM_SCRIPTS != 0) begin
		eth_frame_loop_edit #(C_NUM_SCRIPTS) U4
		(
			.clk(s_axis_clk),
			.rst_n(rst_n_s),

			// S_AXIS

			.s_axis_tdata(axis_cmp2edit_tdata),
			.s_axis_tuser(axis_cmp2edit_tuser),
			.s_axis_tlast(axis_cmp2edit_tlast),
			.s_axis_tvalid(axis_cmp2edit_tvalid),

			// M_AXIS

			.m_axis_tdata(axis_edit2csum_tdata),
			.m_axis_tuser(axis_edit2csum_tuser),
			.m_axis_tlast(axis_edit2csum_tlast),
			.m_axis_tvalid(axis_edit2csum_tvalid)
		);
	end else begin
		always_comb begin
			axis_edit2csum_tdata = axis_cmp2edit_tdata;
			axis_edit2csum_tuser = {9'd0, axis_cmp2edit_tuser[0]};
			axis_edit2csum_tlast = axis_cmp2edit_tlast;
			axis_edit2csum_tvalid = axis_cmp2edit_tvalid;
		end
	end

	logic [7:0] axis_csum2fifo_tdata;
	logic [47:0] axis_csum2fifo_tuser;
	logic axis_csum2fifo_tlast, axis_csum2fifo_tvalid;

	if(C_ENABLE_CHECKSUM && C_NUM_SCRIPTS != 0) begin
		eth_frame_loop_csum U5
		(
			.clk(s_axis_clk),
			.rst_n(rst_n_s),

			// S_AXIS

			.s_axis_tdata(axis_edit2csum_tdata),
			.s_axis_tuser(axis_edit2csum_tuser),
			.s_axis_tlast(axis_edit2csum_tlast),
			.s_axis_tvalid(axis_edit2csum_tvalid),

			// M_AXIS

			.m_axis_tdata(axis_csum2fifo_tdata),
			.m_axis_tuser(axis_csum2fifo_tuser),
			.m_axis_tlast(axis_csum2fifo_tlast),
			.m_axis_tvalid(axis_csum2fifo_tvalid)
		);
	end else begin
		always_comb begin
			axis_csum2fifo_tdata = axis_edit2csum_tdata;
			axis_csum2fifo_tuser = {46'd0, axis_edit2csum_tuser[1:0]};
			axis_csum2fifo_tlast = axis_edit2csum_tlast;
			axis_csum2fifo_tvalid = axis_edit2csum_tvalid;
		end
	end

	logic [7:0] axis_txd_tdata;
	logic axis_txd_tlast, axis_txd_tvalid, axis_txd_tready;

	logic [47:0] axis_txc_tdata;
	logic axis_txc_tvalid, axis_txc_tready;

	eth_frame_loop_fifo #(C_LOOP_FIFO_A_SIZE, C_LOOP_FIFO_B_SIZE) U6
	(
		.clk(s_axis_clk),
		.rst_n(rst_n_s),

		.clk_tx(m_axis_clk),
		.rst_tx_n(rst_n_m),

		// S_AXIS

		.s_axis_tdata(axis_csum2fifo_tdata),
		.s_axis_tuser(axis_csum2fifo_tuser),
		.s_axis_tlast(axis_csum2fifo_tlast),
		.s_axis_tvalid(axis_csum2fifo_tvalid),

		// M_AXIS_FRAME

		.m_axis_frame_tdata(axis_txd_tdata),
		.m_axis_frame_tlast(axis_txd_tlast),
		.m_axis_frame_tvalid(axis_txd_tvalid),
		.m_axis_frame_tready(axis_txd_tready),

		// M_AXIS_CTL

		.m_axis_ctl_tdata(axis_txc_tdata),
		.m_axis_ctl_tvalid(axis_txc_tvalid),
		.m_axis_ctl_tready(axis_txc_tready)
	);

	eth_frame_loop_tx U7
	(
		.clk(m_axis_clk),
		.rst_n(rst_n_m),

		// S_AXIS_FRAME

		.s_axis_frame_tdata(axis_txd_tdata),
		.s_axis_frame_tlast(axis_txd_tlast),
		.s_axis_frame_tvalid(axis_txd_tvalid),
		.s_axis_frame_tready(axis_txd_tready),

		// S_AXIS_CTL

		.s_axis_ctl_tdata(axis_txc_tdata),
		.s_axis_ctl_tvalid(axis_txc_tvalid),
		.s_axis_ctl_tready(axis_txc_tready),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	// AXIS log

	if(C_AXIS_LOG_ENABLE) begin
		localparam C_NUM_SCRIPTS_CEIL = (C_NUM_SCRIPTS <= 8 ? 8 : 16);

		logic [C_AXIS_LOG_WIDTH-1:0] axis_logd_tdata;
		logic axis_logd_tvalid, axis_logd_tready;

		logic [C_NUM_SCRIPTS_CEIL+79:0] axis_logc_tdata;
		logic axis_logc_tvalid, axis_logc_tready;

		eth_frame_loop_extract #(C_NUM_SCRIPTS, C_NUM_SCRIPTS_CEIL, C_AXIS_LOG_WIDTH, C_EXTRACT_FIFO_SIZE) U8
		(
			.clk(s_axis_clk),
			.rst_n(rst_n_s),
			.srst(srst_s),
			.enable(log_en_s),

			.clk_log(clk),
			.current_time(current_time),
			.overflow_count(overflow_count),

			// S_AXIS

			.s_axis_tdata(axis_cmp2edit_tdata),
			.s_axis_tuser(axis_cmp2edit_tuser),
			.s_axis_tlast(axis_cmp2edit_tlast),
			.s_axis_tvalid(axis_cmp2edit_tvalid),

			// M_AXIS_FRAME

			.m_axis_frame_tdata(axis_logd_tdata),
			.m_axis_frame_tvalid(axis_logd_tvalid),
			.m_axis_frame_tready(axis_logd_tready),

			// M_AXIS_CTL

			.m_axis_ctl_tdata(axis_logc_tdata),
			.m_axis_ctl_tvalid(axis_logc_tvalid),
			.m_axis_ctl_tready(axis_logc_tready)
		);

		eth_frame_detector_axis_log #(C_AXIS_LOG_WIDTH, C_DIRECTION_ID, C_NUM_SCRIPTS_CEIL) U9
		(
			.clk(clk),
			.rst_n(rst_n),

			.log_id(log_id),

			// M_AXIS_LOG

			.m_axis_log_tdata(m_axis_log_tdata),
			.m_axis_log_tlast(m_axis_log_tlast),
			.m_axis_log_tvalid(m_axis_log_tvalid),
			.m_axis_log_tready(m_axis_log_tready),

			// S_AXIS_FRAME

			.s_axis_frame_tdata(axis_logd_tdata),
			.s_axis_frame_tvalid(axis_logd_tvalid),
			.s_axis_frame_tready(axis_logd_tready),

			// S_AXIS_CTL

			.s_axis_ctl_tdata(axis_logc_tdata),
			.s_axis_ctl_tvalid(axis_logc_tvalid),
			.s_axis_ctl_tready(axis_logc_tready)
		);
	end
endmodule
