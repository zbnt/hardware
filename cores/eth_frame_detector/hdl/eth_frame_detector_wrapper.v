/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_w
#(
	parameter C_AXI_WIDTH = 32,

	parameter C_AXIS_LOG_ENABLE = 1,
	parameter C_AXIS_LOG_WIDTH = 64,

	parameter C_ENABLE_COMPARE = 1,
	parameter C_ENABLE_EDIT = 1,
	parameter C_ENABLE_CHECKSUM = 1,

	parameter C_NUM_SCRIPTS = 4,
	parameter C_MAX_SCRIPT_SIZE = 2048,
	parameter C_LOOP_FIFO_A_SIZE = 2048,
	parameter C_LOOP_FIFO_B_SIZE = 128,
	parameter C_EXTRACT_FIFO_SIZE = 2048,

	parameter C_SHARED_RX_CLK = 0,
	parameter C_SHARED_TX_CLK = 0,

	parameter C_DEBUG_OUTPUTS = 0
)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input wire s_axi_clk,
	input wire s_axi_resetn,

	input wire [$clog2(4*4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] s_axi_awaddr,
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

	input wire [$clog2(4*4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] s_axi_araddr,
	input wire [2:0] s_axi_arprot,
	input wire s_axi_arvalid,
	output wire s_axi_arready,

	output wire [C_AXI_WIDTH-1:0] s_axi_rdata,
	output wire [1:0] s_axi_rresp,
	output wire s_axi_rvalid,
	input wire s_axi_rready,

	// M_AXIS_A : AXI4-Stream for TX to iface A

	input wire m_axis_a_clk,

	output wire [7:0] m_axis_a_tdata,
	output wire m_axis_a_tuser,
	output wire m_axis_a_tlast,
	output wire m_axis_a_tvalid,
	input wire m_axis_a_tready,

	// S_AXIS_A : AXI4-Stream for RX from iface A

	input wire s_axis_a_clk,

	input wire [7:0] s_axis_a_tdata,
	input wire [2:0] s_axis_a_tuser,
	input wire s_axis_a_tlast,
	input wire s_axis_a_tvalid,

	// M_AXIS_B : AXI4-Stream for TX to iface B

	input wire m_axis_b_clk,

	output wire [7:0] m_axis_b_tdata,
	output wire m_axis_b_tuser,
	output wire m_axis_b_tlast,
	output wire m_axis_b_tvalid,
	input wire m_axis_b_tready,

	// S_AXIS_B : AXI4-Stream for RX from iface B

	input wire s_axis_b_clk,

	input wire [7:0] s_axis_b_tdata,
	input wire [2:0] s_axis_b_tuser,
	input wire s_axis_b_tlast,
	input wire s_axis_b_tvalid,

	// M_AXIS_LOG_A

	output wire [C_AXIS_LOG_WIDTH-1:0] m_axis_log_a_tdata,
	output wire m_axis_log_a_tlast,
	output wire m_axis_log_a_tvalid,
	input wire m_axis_log_a_tready,

	// M_AXIS_LOG_B

	output wire [C_AXIS_LOG_WIDTH-1:0] m_axis_log_b_tdata,
	output wire m_axis_log_b_tlast,
	output wire m_axis_log_b_tvalid,
	input wire m_axis_log_b_tready,

	// DBG_A

	output wire [7:0] dbg_a_rx2cmp_tdata,
	output wire [32*C_NUM_SCRIPTS+2:0] dbg_a_rx2cmp_tuser,
	output wire dbg_a_rx2cmp_tlast,
	output wire dbg_a_rx2cmp_tvalid,

	output wire [7:0] dbg_a_cmp2edit_tdata,
	output wire [17*C_NUM_SCRIPTS+2:0] dbg_a_cmp2edit_tuser,
	output wire dbg_a_cmp2edit_tlast,
	output wire dbg_a_cmp2edit_tvalid,

	output wire [7:0] dbg_a_edit2csum_tdata,
	output wire [10:0] dbg_a_edit2csum_tuser,
	output wire dbg_a_edit2csum_tlast,
	output wire dbg_a_edit2csum_tvalid,

	output wire [7:0] dbg_a_csum2fifo_tdata,
	output wire [49:0] dbg_a_csum2fifo_tuser,
	output wire dbg_a_csum2fifo_tlast,
	output wire dbg_a_csum2fifo_tvalid,

	// DBG_B

	output wire [7:0] dbg_b_rx2cmp_tdata,
	output wire [32*C_NUM_SCRIPTS+2:0] dbg_b_rx2cmp_tuser,
	output wire dbg_b_rx2cmp_tlast,
	output wire dbg_b_rx2cmp_tvalid,

	output wire [7:0] dbg_b_cmp2edit_tdata,
	output wire [17*C_NUM_SCRIPTS+2:0] dbg_b_cmp2edit_tuser,
	output wire dbg_b_cmp2edit_tlast,
	output wire dbg_b_cmp2edit_tvalid,

	output wire [7:0] dbg_b_edit2csum_tdata,
	output wire [10:0] dbg_b_edit2csum_tuser,
	output wire dbg_b_edit2csum_tlast,
	output wire dbg_b_edit2csum_tvalid,

	output wire [7:0] dbg_b_csum2fifo_tdata,
	output wire [49:0] dbg_b_csum2fifo_tuser,
	output wire dbg_b_csum2fifo_tlast,
	output wire dbg_b_csum2fifo_tvalid,

	// Timer

	input wire [63:0] current_time,
	input wire time_running
);
	eth_frame_detector
	#(
		C_AXI_WIDTH,

		C_AXIS_LOG_ENABLE,
		C_AXIS_LOG_WIDTH,

		C_ENABLE_COMPARE,
		C_ENABLE_EDIT,
		C_ENABLE_CHECKSUM,

		C_NUM_SCRIPTS,
		C_MAX_SCRIPT_SIZE,
		C_LOOP_FIFO_A_SIZE,
		C_LOOP_FIFO_B_SIZE,
		C_EXTRACT_FIFO_SIZE,

		C_SHARED_RX_CLK,
		C_SHARED_TX_CLK
	)
	U0
	(
		// S_AXI

		.s_axi_clk(s_axi_clk),
		.s_axi_resetn(s_axi_resetn),

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

		// M_AXIS_A

		.m_axis_a_clk(m_axis_a_clk),

		.m_axis_a_tdata(m_axis_a_tdata),
		.m_axis_a_tuser(m_axis_a_tuser),
		.m_axis_a_tlast(m_axis_a_tlast),
		.m_axis_a_tvalid(m_axis_a_tvalid),
		.m_axis_a_tready(m_axis_a_tready),

		// S_AXIS_A

		.s_axis_a_clk(s_axis_a_clk),

		.s_axis_a_tdata(s_axis_a_tdata),
		.s_axis_a_tuser(s_axis_a_tuser),
		.s_axis_a_tlast(s_axis_a_tlast),
		.s_axis_a_tvalid(s_axis_a_tvalid),

		// M_AXIS_B

		.m_axis_b_clk(m_axis_b_clk),

		.m_axis_b_tdata(m_axis_b_tdata),
		.m_axis_b_tuser(m_axis_b_tuser),
		.m_axis_b_tlast(m_axis_b_tlast),
		.m_axis_b_tvalid(m_axis_b_tvalid),
		.m_axis_b_tready(m_axis_b_tready),

		// S_AXIS_B

		.s_axis_b_clk(s_axis_b_clk),

		.s_axis_b_tdata(s_axis_b_tdata),
		.s_axis_b_tuser(s_axis_b_tuser),
		.s_axis_b_tlast(s_axis_b_tlast),
		.s_axis_b_tvalid(s_axis_b_tvalid),

		// M_AXIS_LOG_A

		.m_axis_log_a_tdata(m_axis_log_a_tdata),
		.m_axis_log_a_tlast(m_axis_log_a_tlast),
		.m_axis_log_a_tvalid(m_axis_log_a_tvalid),
		.m_axis_log_a_tready(m_axis_log_a_tready),

		// M_AXIS_LOG_B

		.m_axis_log_b_tdata(m_axis_log_b_tdata),
		.m_axis_log_b_tlast(m_axis_log_b_tlast),
		.m_axis_log_b_tvalid(m_axis_log_b_tvalid),
		.m_axis_log_b_tready(m_axis_log_b_tready),

		// DBG_A

		.dbg_a_rx2cmp_tdata(dbg_a_rx2cmp_tdata),
		.dbg_a_rx2cmp_tuser(dbg_a_rx2cmp_tuser),
		.dbg_a_rx2cmp_tlast(dbg_a_rx2cmp_tlast),
		.dbg_a_rx2cmp_tvalid(dbg_a_rx2cmp_tvalid),

		.dbg_a_cmp2edit_tdata(dbg_a_cmp2edit_tdata),
		.dbg_a_cmp2edit_tuser(dbg_a_cmp2edit_tuser),
		.dbg_a_cmp2edit_tlast(dbg_a_cmp2edit_tlast),
		.dbg_a_cmp2edit_tvalid(dbg_a_cmp2edit_tvalid),

		.dbg_a_edit2csum_tdata(dbg_a_edit2csum_tdata),
		.dbg_a_edit2csum_tuser(dbg_a_edit2csum_tuser),
		.dbg_a_edit2csum_tlast(dbg_a_edit2csum_tlast),
		.dbg_a_edit2csum_tvalid(dbg_a_edit2csum_tvalid),

		.dbg_a_csum2fifo_tdata(dbg_a_csum2fifo_tdata),
		.dbg_a_csum2fifo_tuser(dbg_a_csum2fifo_tuser),
		.dbg_a_csum2fifo_tlast(dbg_a_csum2fifo_tlast),
		.dbg_a_csum2fifo_tvalid(dbg_a_csum2fifo_tvalid),

		// DBG_B

		.dbg_b_rx2cmp_tdata(dbg_b_rx2cmp_tdata),
		.dbg_b_rx2cmp_tuser(dbg_b_rx2cmp_tuser),
		.dbg_b_rx2cmp_tlast(dbg_b_rx2cmp_tlast),
		.dbg_b_rx2cmp_tvalid(dbg_b_rx2cmp_tvalid),

		.dbg_b_cmp2edit_tdata(dbg_b_cmp2edit_tdata),
		.dbg_b_cmp2edit_tuser(dbg_b_cmp2edit_tuser),
		.dbg_b_cmp2edit_tlast(dbg_b_cmp2edit_tlast),
		.dbg_b_cmp2edit_tvalid(dbg_b_cmp2edit_tvalid),

		.dbg_b_edit2csum_tdata(dbg_b_edit2csum_tdata),
		.dbg_b_edit2csum_tuser(dbg_b_edit2csum_tuser),
		.dbg_b_edit2csum_tlast(dbg_b_edit2csum_tlast),
		.dbg_b_edit2csum_tvalid(dbg_b_edit2csum_tvalid),

		.dbg_b_csum2fifo_tdata(dbg_b_csum2fifo_tdata),
		.dbg_b_csum2fifo_tuser(dbg_b_csum2fifo_tuser),
		.dbg_b_csum2fifo_tlast(dbg_b_csum2fifo_tlast),
		.dbg_b_csum2fifo_tvalid(dbg_b_csum2fifo_tvalid),

		// Timer

		.current_time(current_time),
		.time_running(time_running)
	);
endmodule
