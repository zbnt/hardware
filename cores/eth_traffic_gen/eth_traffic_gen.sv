/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen #(parameter mem_addr_width = 6, parameter mem_size = 4)
(
	// S_AXI : AXI4-Lite slave interface (from PS)

	input logic s_axi_clk,
	input logic s_axi_resetn,

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

	input logic axis_clk,
	input logic axis_reset,

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS : AXI4-Stream slave interface (from FIFO)

	input logic [31:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	// MEM_A : Memory port A (read/written by S_AXI)

	output logic [mem_addr_width-1:0] mem_a_addr,
	output logic [7:0] mem_a_wdata,
	output logic mem_a_we,
	input logic [7:0] mem_a_rdata,

	// MEM_B : Memory port B (read by M_AXIS)

	output logic [mem_addr_width-1:0] mem_b_addr,
	input logic [7:0] mem_b_rdata,

	// IFG control (to TEMAC)

	output logic [7:0] ifg_delay
);
	logic [31:0] reg_val[0:2];
	logic [31:0] frame_delay;
	logic fifo_trigger;

	eth_traffic_gen_axi #(mem_addr_width, mem_size, 4, 3, 3'b011) U0
	(
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

		.mem_a_addr(mem_a_addr),
		.mem_a_wdata(mem_a_wdata),
		.mem_a_we(mem_a_we),
		.mem_a_rdata(mem_a_rdata),

		.reg_val(reg_val),
		.reg_in({reg_val[0:1], frame_delay})
	);

	eth_traffic_gen_axis #(mem_addr_width, mem_size) U1
	(
		.clk(axis_clk),
		.rst(axis_reset),

		.tx_begin(fifo_trigger),

		.enable(reg_val[0][0]),
		.headers_size(reg_val[1][15:0]),
		.payload_size(reg_val[1][31:16]),
		.frame_delay(frame_delay),

		.mem_addr(mem_b_addr),
		.mem_rdata(mem_b_rdata),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	eth_traffic_gen_fifo U2
	(
		.clk(axis_clk),
		.rst(axis_reset),
		.trigger(fifo_trigger),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		.frame_delay(frame_delay)
	);

	always_comb begin
		ifg_delay = 8'd0;
	end
endmodule

