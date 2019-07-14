/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module loop_fifo
(
	input logic m_aclk,
	input logic s_aclk,
	input logic s_aresetn,

	output logic axis_prog_full,
	output logic axis_prog_empty,

	input logic [8:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	output logic [8:0] m_axis_tdata,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("independent_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(512),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(384),
		.PROG_FULL_THRESH(448),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(8),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("0202"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U0
	(
		.m_aclk(m_aclk),
		.s_aclk(s_aclk),
		.s_aresetn(s_aresetn),

		.prog_full_axis(axis_prog_full),
		.prog_empty_axis(axis_prog_empty),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule
