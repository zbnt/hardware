/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	eth_frame_detector: Ethernet Frame Detector

	This module connects two network interfaces, behaving like a MitM. Received frames are stored in a FIFO
	and transmitted on the other interface. Incoming data is compared	against a set of user-configurable
	patterns and if a match is found, the current timestamp is stored in a FIFO together with information
	regarding the matched patterns.
*/

module eth_frame_detector
#(
	parameter C_AXI_WIDTH = 32,

	parameter C_AXIS_LOG_ENABLE = 1,
	parameter C_AXIS_LOG_WIDTH = 64,

	parameter C_ENABLE_COMPARE = 1,
	parameter C_ENABLE_EDIT = 1,
	parameter C_ENABLE_CHECKSUM = 1,

	parameter C_NUM_SCRIPTS = 4,
	parameter C_MAX_SCRIPT_SIZE = 2048,
	parameter C_LOOP_FIFO_SIZE = 2048,
	parameter C_EXTRACT_FIFO_SIZE = 2048,

	parameter C_SHARED_RX_CLK = 0,
	parameter C_SHARED_TX_CLK = 0
)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

	input logic [$clog2(4*4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [$clog2(4*4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// M_AXIS_A : AXI4-Stream master interface (to TEMAC of iface A)

	input logic m_axis_a_clk,

	output logic [7:0] m_axis_a_tdata,
	output logic m_axis_a_tuser,
	output logic m_axis_a_tlast,
	output logic m_axis_a_tvalid,
	input logic m_axis_a_tready,

	// S_AXIS_A : AXI4-Stream slave interface (from TEMAC of iface A)

	input logic s_axis_a_clk,

	input logic [7:0] s_axis_a_tdata,
	input logic s_axis_a_tuser,
	input logic s_axis_a_tlast,
	input logic s_axis_a_tvalid,

	// M_AXIS_B : AXI4-Stream master interface (to TEMAC of iface B)

	input logic m_axis_b_clk,

	output logic [7:0] m_axis_b_tdata,
	output logic m_axis_b_tuser,
	output logic m_axis_b_tlast,
	output logic m_axis_b_tvalid,
	input logic m_axis_b_tready,

	// S_AXIS_B : AXI4-Stream slave interface (from TEMAC of iface B)

	input logic s_axis_b_clk,

	input logic [7:0] s_axis_b_tdata,
	input logic s_axis_b_tuser,
	input logic s_axis_b_tlast,
	input logic s_axis_b_tvalid,

	// M_AXIS_LOG_A

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_a_tdata,
	output logic m_axis_log_a_tlast,
	output logic m_axis_log_a_tvalid,
	input logic m_axis_log_a_tready,

	// M_AXIS_LOG_B

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_b_tdata,
	output logic m_axis_log_b_tlast,
	output logic m_axis_log_b_tvalid,
	input logic m_axis_log_b_tready,

	// Timer

	input logic [63:0] current_time,
	input logic time_running
);
	logic enable, srst, log_en, log_en_req;
	logic [2*C_NUM_SCRIPTS-1:0] script_en, script_en_req;
	logic [15:0] log_id;
	logic [63:0] overflow_count_a, overflow_count_b;

	logic [$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] mem_a_addr;
	logic mem_a_req, mem_a_wenable, mem_a_ack;
	logic [C_AXI_WIDTH-1:0] mem_a_wdata;
	logic [C_AXI_WIDTH-1:0] mem_a_rdata;

	logic [$clog2(4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE)-1:0] mem_b_addr;
	logic mem_b_req, mem_b_wenable, mem_b_ack;
	logic [C_AXI_WIDTH-1:0] mem_b_wdata;
	logic [C_AXI_WIDTH-1:0] mem_b_rdata;

	always_ff @(posedge s_axi_clk) begin
		if(~s_axi_resetn | ~enable | ~time_running | srst) begin
			log_en <= 1'b0;
			script_en <= '0;
		end else begin
			log_en <= log_en_req;
			script_en <= script_en_req;
		end
	end

	// Registers

	eth_frame_detector_axi #(C_AXI_WIDTH, $clog2(4*4*C_NUM_SCRIPTS*C_MAX_SCRIPT_SIZE), C_AXIS_LOG_ENABLE, C_NUM_SCRIPTS) U0
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

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

		// MEM_A

		.mem_a_req(mem_a_req),
		.mem_a_addr(mem_a_addr),
		.mem_a_wenable(mem_a_wenable),
		.mem_a_wdata(mem_a_wdata),
		.mem_a_rdata(mem_a_rdata),
		.mem_a_ack(mem_a_ack),

		// MEM_B

		.mem_b_req(mem_b_req),
		.mem_b_addr(mem_b_addr),
		.mem_b_wenable(mem_b_wenable),
		.mem_b_wdata(mem_b_wdata),
		.mem_b_rdata(mem_b_rdata),
		.mem_b_ack(mem_b_ack),

		// Registers

		.enable(enable),
		.srst(srst),
		.log_en(log_en_req),
		.script_en(script_en_req),
		.log_id(log_id),

		.overflow_count_a(overflow_count_a),
		.overflow_count_b(overflow_count_b)
	);

	// Interface loops

	eth_frame_loop
	#(
		C_AXI_WIDTH,
		C_AXIS_LOG_ENABLE,
		C_AXIS_LOG_WIDTH,
		65,
		C_ENABLE_COMPARE,
		C_ENABLE_EDIT,
		C_ENABLE_CHECKSUM,
		C_NUM_SCRIPTS,
		C_MAX_SCRIPT_SIZE,
		C_LOOP_FIFO_SIZE,
		C_EXTRACT_FIFO_SIZE,
		C_SHARED_RX_CLK,
		C_SHARED_TX_CLK
	)
	U3
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),
		.srst(srst),

		.log_en(log_en),
		.script_en(script_en[C_NUM_SCRIPTS-1:0]),

		.log_id(log_id),
		.current_time(current_time),
		.overflow_count(overflow_count_a),

		// MEM

		.mem_req(mem_a_req),
		.mem_addr(mem_a_addr),
		.mem_wenable(mem_a_wenable),
		.mem_wdata(mem_a_wdata),
		.mem_rdata(mem_a_rdata),
		.mem_ack(mem_a_ack),

		// M_AXIS_LOG

		.m_axis_log_tdata(m_axis_log_a_tdata),
		.m_axis_log_tlast(m_axis_log_a_tlast),
		.m_axis_log_tvalid(m_axis_log_a_tvalid),
		.m_axis_log_tready(m_axis_log_a_tready),

		// M_AXIS_B

		.m_axis_clk(m_axis_b_clk),

		.m_axis_tdata(m_axis_b_tdata),
		.m_axis_tuser(m_axis_b_tuser),
		.m_axis_tlast(m_axis_b_tlast),
		.m_axis_tvalid(m_axis_b_tvalid),
		.m_axis_tready(m_axis_b_tready),

		// S_AXIS_A

		.s_axis_clk(s_axis_a_clk),

		.s_axis_tdata(s_axis_a_tdata),
		.s_axis_tuser(s_axis_a_tuser),
		.s_axis_tlast(s_axis_a_tlast),
		.s_axis_tvalid(s_axis_a_tvalid)
	);

	eth_frame_loop
	#(
		C_AXI_WIDTH,
		C_AXIS_LOG_ENABLE,
		C_AXIS_LOG_WIDTH,
		66,
		C_ENABLE_COMPARE,
		C_ENABLE_EDIT,
		C_ENABLE_CHECKSUM,
		C_NUM_SCRIPTS,
		C_MAX_SCRIPT_SIZE,
		C_LOOP_FIFO_SIZE,
		C_EXTRACT_FIFO_SIZE,
		C_SHARED_RX_CLK,
		C_SHARED_TX_CLK
	)
	U4
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),
		.srst(srst),

		.log_en(log_en),
		.script_en(script_en[2*C_NUM_SCRIPTS-1:C_NUM_SCRIPTS]),

		.log_id(log_id),
		.current_time(current_time),
		.overflow_count(overflow_count_b),

		// MEM

		.mem_req(mem_b_req),
		.mem_addr(mem_b_addr),
		.mem_wenable(mem_b_wenable),
		.mem_wdata(mem_b_wdata),
		.mem_rdata(mem_b_rdata),
		.mem_ack(mem_b_ack),

		// M_AXIS_LOG

		.m_axis_log_tdata(m_axis_log_b_tdata),
		.m_axis_log_tlast(m_axis_log_b_tlast),
		.m_axis_log_tvalid(m_axis_log_b_tvalid),
		.m_axis_log_tready(m_axis_log_b_tready),

		// M_AXIS_A

		.m_axis_clk(m_axis_a_clk),

		.m_axis_tdata(m_axis_a_tdata),
		.m_axis_tuser(m_axis_a_tuser),
		.m_axis_tlast(m_axis_a_tlast),
		.m_axis_tvalid(m_axis_a_tvalid),
		.m_axis_tready(m_axis_a_tready),

		// S_AXIS_B

		.s_axis_clk(s_axis_b_clk),

		.s_axis_tdata(s_axis_b_tdata),
		.s_axis_tuser(s_axis_b_tuser),
		.s_axis_tlast(s_axis_b_tlast),
		.s_axis_tvalid(s_axis_b_tvalid)
	);
endmodule
