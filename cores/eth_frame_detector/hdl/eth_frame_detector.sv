/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core eth_frame_detector: Ethernet Frame Detector

	This module connects two network interfaces, behaving like a MitM. Frames received are stored in a FIFO
	and transmitted on the other interface without any modification. At the same time, incoming data is compared
	against a set of user-configurable patterns and if a match is found, the current timestamp is stored in a FIFO
	together with information regarding the matched patterns.

	\supports
		\device zynq Production

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite
			\clk  s_axi_clk

		\iface m_axis_a: Transmission stream for the TEMAC A.
			\type AXI4-Stream
			\clk  s_axi_clk

		\iface m_axis_b: Transmission stream for the TEMAC B.
			\type AXI4-Stream
			\clk  s_axi_clk

		\iface s_axis_a: Reception stream for the TEMAC A.
			\type AXI4-Stream
			\clk  s_axis_a_clk

		\iface s_axis_b: Reception stream for the TEMAC B.
			\type AXI4-Stream
			\clk  s_axis_b_clk

	\memorymap S_AXI_ADDR
		\regsize 32

		\reg FD_CFG: Frame detector configuration register.
			\access RW

			\field EN     0      Global enable, set to 1 in order to enable frame detection.
			\field SRST   1      Software reset, active high, must be set back to 0 again manually.
			\field ENA1   2      Enable pattern A1.
			\field ENA2   3      Enable pattern A2.
			\field ENA3   4      Enable pattern A3.
			\field ENB1   5      Enable pattern B1.
			\field ENB2   6      Enable pattern B2.
			\field ENB3   7      Enable pattern B3.

		\reg FD_FIFO_OCCUP: FIFO occupancy.
			\access RO

			\field FOCCUP 0-10   Number of entries currently stored in the FIFO.

		\reg FD_FIFO_POP: Read values from FIFO.
			\access RW

			\field FPOP   0-31   If set to a value different from 0, read the next set of values from the FIFO and store them in
			                     the registers. If read, always returns 0.

		\reg FD_RSVD: Reserved.
			\access RO

		\reg FD_TIME_L: Detection time, lower half.
			\access RO

			\field TIMEL  0-31   Time of the last detection, lower 32 bits.

		\reg FD_TIME_H: Detection time, upper half.
			\access RO

			\field TIMEH  0-31   Time of the last detection, upper 32 bits.

		\reg FD_MATCHED: Matched patterns.
			\access RO

			\field MA1    0      Set to 1 if a match for pattern A1 was detected.
			\field MA2    1      Set to 1 if a match for pattern A2 was detected.
			\field MA3    2      Set to 1 if a match for pattern A3 was detected.
			\field MB1    3      Set to 1 if a match for pattern B1 was detected.
			\field MB2    4      Set to 1 if a match for pattern B2 was detected.
			\field MB3    5      Set to 1 if a match for pattern B3 was detected.

		\mem PATTERN_MEM_A: Patterns for frames going from A to B.
			\access RW
			\at    0x2000
			\size  3072

		\mem PATTERN_MEM_B: Patterns for frames going from B to A.
			\access RW
			\at    0x4000
			\size  3072
*/

module eth_frame_detector #(parameter axi_width = 32)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

	input logic [15:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [axi_width-1:0] s_axi_wdata,
	input logic [(axi_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [15:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [axi_width-1:0] s_axi_rdata,
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

	output logic [15:0] pause_a_val,
	output logic pause_a_req,

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

	output logic [15:0] pause_b_val,
	output logic pause_b_req,

	// S_AXIS_B : AXI4-Stream slave interface (from TEMAC of iface B)

	input logic s_axis_b_clk,

	input logic [7:0] s_axis_b_tdata,
	input logic s_axis_b_tuser,
	input logic s_axis_b_tlast,
	input logic s_axis_b_tvalid,

	// Timer

	input logic [63:0] current_time,
	input logic time_running
);
	// axi4_lite registers

	logic srst;
	logic [5:0] match_en;
	logic [5:0] match_mode;
	logic [2:0] match_a, match_b;
	logic [1:0] match_a_id, match_b_id;

	logic mem_a_pa_req, mem_a_pa_we, mem_a_pa_ack;
	logic mem_b_pa_req, mem_b_pa_we, mem_b_pa_ack;

	logic [10:0] mem_a_pa_addr;
	logic [10:0] mem_b_pa_addr;

	logic [30*(axi_width/32)-1:0] mem_a_pa_wdata, mem_a_pa_rdata;
	logic [30*(axi_width/32)-1:0] mem_b_pa_wdata, mem_b_pa_rdata;

	eth_frame_detector_axi #(axi_width) U0
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

		// MEM_A_PA

		.mem_a_req(mem_a_pa_req),
		.mem_a_we(mem_a_pa_we),
		.mem_a_ack(mem_a_pa_ack),

		.mem_a_addr(mem_a_pa_addr),
		.mem_a_wdata(mem_a_pa_wdata),
		.mem_a_rdata(mem_a_pa_rdata),

		// MEM_B_PA

		.mem_b_req(mem_b_pa_req),
		.mem_b_we(mem_b_pa_we),
		.mem_b_ack(mem_b_pa_ack),

		.mem_b_addr(mem_b_pa_addr),
		.mem_b_wdata(mem_b_pa_wdata),
		.mem_b_rdata(mem_b_pa_rdata),

		// Registers

		.srst(srst),
		.match_en(match_en),

		// Status

		.current_time(current_time),
		.time_running(time_running),

		.match_a(match_a),
		.match_a_id(match_a_id),

		.match_b(match_b),
		.match_b_id(match_b_id)
	);

	// Interface loop, transmit frames received from one interface through the other

	eth_frame_loop U1
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		// M_AXIS_A

		.m_axis_clk(m_axis_a_clk),

		.m_axis_tdata(m_axis_a_tdata),
		.m_axis_tuser(m_axis_a_tuser),
		.m_axis_tlast(m_axis_a_tlast),
		.m_axis_tvalid(m_axis_a_tvalid),
		.m_axis_tready(m_axis_a_tready),

		.pause_val(pause_a_val),
		.pause_req(pause_a_req),

		// S_AXIS_B

		.s_axis_clk(s_axis_b_clk),

		.s_axis_tdata(s_axis_b_tdata),
		.s_axis_tuser(s_axis_b_tuser),
		.s_axis_tlast(s_axis_b_tlast),
		.s_axis_tvalid(s_axis_b_tvalid)
	);

	eth_frame_loop U2
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		// M_AXIS_B

		.m_axis_clk(m_axis_b_clk),

		.m_axis_tdata(m_axis_b_tdata),
		.m_axis_tuser(m_axis_b_tuser),
		.m_axis_tlast(m_axis_b_tlast),
		.m_axis_tvalid(m_axis_b_tvalid),
		.m_axis_tready(m_axis_b_tready),

		.pause_val(pause_b_val),
		.pause_req(pause_b_req),

		// S_AXIS_A

		.s_axis_clk(s_axis_a_clk),

		.s_axis_tdata(s_axis_a_tdata),
		.s_axis_tuser(s_axis_a_tuser),
		.s_axis_tlast(s_axis_a_tlast),
		.s_axis_tvalid(s_axis_a_tvalid)
	);

	// Match received frames against the stored patterns

	logic [29:0] mem_a_pb_data, mem_b_pb_data;
	logic [10:0] mem_a_pb_addr, mem_b_pb_addr;

	eth_frame_matcher U3
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		.match(match_a),
		.match_id(match_a_id),
		.match_en(match_en[2:0]),

		// S_AXIS_A

		.s_axis_clk(s_axis_a_clk),

		.s_axis_tdata(s_axis_a_tdata),
		.s_axis_tuser(s_axis_a_tuser),
		.s_axis_tlast(s_axis_a_tlast),
		.s_axis_tvalid(s_axis_a_tvalid),

		// MEM_A

		.mem_data(mem_a_pb_data),
		.mem_addr(mem_a_pb_addr)
	);

	eth_frame_matcher U4
	(
		.clk(s_axi_clk),
		.rst_n(s_axi_resetn),

		.match(match_b),
		.match_id(match_b_id),
		.match_en(match_en[5:3]),

		// S_AXIS_B

		.s_axis_clk(s_axis_b_clk),

		.s_axis_tdata(s_axis_b_tdata),
		.s_axis_tuser(s_axis_b_tuser),
		.s_axis_tlast(s_axis_b_tlast),
		.s_axis_tvalid(s_axis_b_tvalid),

		// MEM_B

		.mem_data(mem_b_pb_data),
		.mem_addr(mem_b_pb_addr)
	);

	// Memory for storing patterns, one for each direction

	eth_frame_pattern_mem #(axi_width) U5
	(
		.clk(s_axi_clk),

		// MEM_A_PA

		.mem_pa_req(mem_a_pa_req),
		.mem_pa_we(mem_a_pa_we),
		.mem_pa_ack(mem_a_pa_ack),

		.mem_pa_addr(mem_a_pa_addr),
		.mem_pa_wdata(mem_a_pa_wdata),
		.mem_pa_rdata(mem_a_pa_rdata),

		// MEM_A_PB

		.mem_pb_clk(s_axis_a_clk),
		.mem_pb_addr(mem_a_pb_addr),
		.mem_pb_rdata(mem_a_pb_data)
	);

	eth_frame_pattern_mem #(axi_width) U6
	(
		.clk(s_axi_clk),

		// MEM_B_PA

		.mem_pa_req(mem_b_pa_req),
		.mem_pa_we(mem_b_pa_we),
		.mem_pa_ack(mem_b_pa_ack),

		.mem_pa_addr(mem_b_pa_addr),
		.mem_pa_wdata(mem_b_pa_wdata),
		.mem_pa_rdata(mem_b_pa_rdata),

		// MEM_B_PB

		.mem_pb_clk(s_axis_b_clk),
		.mem_pb_addr(mem_b_pb_addr),
		.mem_pb_rdata(mem_b_pb_data)
	);
endmodule
