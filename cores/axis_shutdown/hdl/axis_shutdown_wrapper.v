/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module axis_shutdown_w
#(
	parameter C_CDC_STAGES = 0,

	parameter C_AXIS_TDATA_WIDTH = 32,
	parameter C_AXIS_TUSER_WIDTH = 1,
	parameter C_AXIS_TDEST_WIDTH = 1,
	parameter C_AXIS_TID_WIDTH = 1,

	parameter C_AXIS_HAS_TREADY = 1,
	parameter C_AXIS_HAS_TSTRB = 0,
	parameter C_AXIS_HAS_TKEEP = 0,
	parameter C_AXIS_HAS_TLAST = 1,
	parameter C_AXIS_HAS_TID = 0,
	parameter C_AXIS_HAS_TDEST = 0,
	parameter C_AXIS_HAS_TUSER = 0,

	parameter C_TREADY_IN_SHUTDOWN = 0
)
(
	input wire clk,
	input wire rst_n,

	input wire shutdown_clk,
	input wire shutdown_req,
	output wire shutdown_ack,

	// S_AXIS

	input wire [C_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
	input wire [(C_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb,
	input wire [(C_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tkeep,
	input wire [C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
	input wire [C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
	input wire [C_AXIS_TID_WIDTH-1:0] s_axis_tid,
	input wire s_axis_tlast,
	input wire s_axis_tvalid,
	output wire s_axis_tready,

	// M_AXIS

	output wire [C_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
	output wire [(C_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tstrb,
	output wire [(C_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tkeep,
	output wire [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
	output wire [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest,
	output wire [C_AXIS_TID_WIDTH-1:0] m_axis_tid,
	output wire m_axis_tlast,
	output wire m_axis_tvalid,
	input wire m_axis_tready
);
	wire rst_n_cdc, req, ack;

	axis_shutdown
	#(
		C_AXIS_TDATA_WIDTH,
		C_AXIS_TUSER_WIDTH,
		C_AXIS_TDEST_WIDTH,
		C_AXIS_TID_WIDTH,

		C_AXIS_HAS_TREADY,
		C_AXIS_HAS_TSTRB,
		C_AXIS_HAS_TKEEP,
		C_AXIS_HAS_TLAST,
		C_AXIS_HAS_TID,
		C_AXIS_HAS_TDEST,
		C_AXIS_HAS_TUSER,

		C_TREADY_IN_SHUTDOWN
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n_cdc),

		.shutdown_req(req),
		.shutdown_ack(ack),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tstrb(s_axis_tstrb),
		.s_axis_tkeep(s_axis_tkeep),
		.s_axis_tuser(s_axis_tuser),
		.s_axis_tdest(s_axis_tdest),
		.s_axis_tid(s_axis_tid),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tstrb(m_axis_tstrb),
		.m_axis_tkeep(m_axis_tkeep),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tdest(m_axis_tdest),
		.m_axis_tid(m_axis_tid),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready)
	);

	if(C_CDC_STAGES != 0) begin
		xpm_cdc_sync_rst
		#(
			.DEST_SYNC_FF(C_CDC_STAGES)
		)
		U1
		(
			.src_rst(rst_n),

			.dest_clk(clk),
			.dest_rst(rst_n_cdc)
		);

		xpm_cdc_array_single
		#(
			.DEST_SYNC_FF(C_CDC_STAGES),
			.WIDTH(1)
		)
		U2
		(
			.src_clk(shutdown_clk),
			.src_in(shutdown_req),

			.dest_clk(clk),
			.dest_out(req)
		);

		xpm_cdc_array_single
		#(
			.DEST_SYNC_FF(C_CDC_STAGES),
			.WIDTH(1)
		)
		U3
		(
			.src_clk(clk),
			.src_in(ack),

			.dest_clk(shutdown_clk),
			.dest_out(shutdown_ack)
		);
	end else begin
		assign rst_n_cdc = rst_n;
		assign req = shutdown_req;
		assign shutdown_ack = ack;
	end
endmodule
