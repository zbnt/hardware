/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	\core eth_traffic_gen: Ethernet Traffic Generator

	This core generates a stream of ethernet frames by combining headers stored in DRAM and pseudo-random data
	obtained from a _linear-feedback shift register_. The core provides an AXI4-Lite interface that allows the
	user to adjust the contents of the frame headers, the size of the pseudo-random payload and the idle time
	between generated frames.

	\supports
		\device zynq Production

	\ports
		\iface s_axi: Configuration interface from PS.
			\type AXI4-Lite

			\clk  s_axi_clk
			\rst_n s_axi_resetn

		\iface m_axis: Data stream to MAC.
			\type AXI4-Stream

			\clk axis_clk
			\rst axis_reset

	\memorymap S_AXI_ADDR
		\regsize 32

		\reg TG_CFG: TGen configuration register.
			\access RW

			\field EN     0      Enable traffic generation.
			\field FRST   1      Reset internal FIFOs.
			\field FDSRC  2      Frame delay source.
			\field PSSRC  3      Payload size source.

		\reg TG_STATUS: TGen status register.
			\access RO

			\field BUSY   0	   Busy flag, set to 1 if there is a frame transmission in progress.
			\field TXST   1-2    Frame transmission FSM state.
			\field DRPTR  3-13   Pointer to the internal DRAM address currently being transmitted.

		\reg TG_HSIZE: Frame headers size.
			\access RW

			\field HSIZE  0-11   Number of bytes from DRAM to read and send, must be between 14 and 2048, inclusive.

		\reg TG_FDELAY: Sleep time after frame transmission.
			\access RW

			\field FDELAY 0-31   Number of clock cycles to wait before starting to send the next frame.

		\reg TG_PSIZE: Frame payload size.
			\access RW

			\field PSIZE  0-15   Number of pseudo-random bytes to send.

		\reg TG_FIFO_OCCUP: FIFO occupancy.
			\access RO

			\field FDFOCC 0-10   Number of values in the frame delay FIFO.
			\field PSFOCC 16-26  Number of values in the payload size FIFO.

		\mem FRAME_HEADERS: Headers for the generated frames.
			\access RW
			\at    0x800
			\size  2048
*/

module eth_traffic_gen
(
	input logic clk,
	input logic rst_n,

	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic [11:0] s_axi_awaddr,
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

	input logic [11:0] s_axi_araddr,
	input logic [2:0] s_axi_arprot,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [31:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	input logic s_axi_rready,

	// M_AXIS : AXI4-Stream master interface (to TEMAC)

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic fifo_trigger;
	logic fifo_ready;

	logic tx_enable;
	logic tx_busy;
	logic [1:0] tx_state;
	logic [11:0] headers_size;
	logic [15:0] payload_size;
	logic [31:0] frame_delay;

	logic [7:0] mem_a_wdata, mem_a_rdata, mem_b_rdata;
	logic [10:0] mem_a_addr, mem_b_addr;
	logic mem_a_we;

	eth_traffic_gen_axi U0
	(
		.clk(clk),
		.rst_n(rst_n),

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

		.mem_addr(mem_a_addr),
		.mem_wdata(mem_a_wdata),
		.mem_we(mem_a_we),
		.mem_rdata(mem_a_rdata),

		.fifo_trigger(fifo_trigger),
		.fifo_ready(fifo_ready),

		.tx_enable(tx_enable),

		.tx_busy(tx_busy),
		.tx_state(tx_state),
		.tx_ptr(mem_b_addr),

		.headers_size(headers_size),
		.payload_size(payload_size),
		.frame_delay(frame_delay)
	);

	eth_traffic_gen_axis U1
	(
		.clk(clk),
		.rst(~rst_n),

		.tx_begin(fifo_trigger),
		.tx_busy(tx_busy),
		.tx_state(tx_state),

		.enable(tx_enable),
		.fifo_ready(fifo_ready),
		.headers_size(headers_size),
		.payload_size(payload_size),
		.frame_delay(frame_delay),

		.mem_addr(mem_b_addr),
		.mem_rdata(mem_b_rdata),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	frame_dram U2
	(
		.clk(clk),

		.a(mem_a_addr),
		.d(mem_a_wdata),
		.spo(mem_a_rdata),
		.we(mem_a_we),

		.dpra(mem_b_addr),
		.dpo(mem_b_rdata)
	);
endmodule

