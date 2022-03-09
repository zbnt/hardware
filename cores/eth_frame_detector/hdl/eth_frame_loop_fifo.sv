/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_fifo #(parameter C_LOOP_FIFO_A_SIZE = 2048, parameter C_LOOP_FIFO_B_SIZE = 128)
(
	input logic clk,
	input logic rst_n,

	input logic clk_tx,
	input logic rst_tx_n,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [49:0] s_axis_tuser, // {FCS_ACTIVE, UPDATE_FCS, IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, CORRUPT_FRAME}
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// M_AXIS_FRAME

	output logic [7:0] m_axis_frame_tdata,
	output logic m_axis_frame_tuser,
	output logic m_axis_frame_tlast,
	output logic m_axis_frame_tvalid,
	input logic m_axis_frame_tready,

	// M_AXIS_CTL

	output logic [48:0] m_axis_ctl_tdata, // {UPDATE_FCS, IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, CORRUPT_FRAME}
	output logic m_axis_ctl_tvalid,
	input logic m_axis_ctl_tready
);
	enum logic [2:0] {ST_WAIT_FIFO, ST_WRITE_FRAME, ST_WRITE_CTL, ST_OVERFLOW_A, ST_OVERFLOW_B} state, state_next;

	logic [7:0] s_axis_frame_tdata;
	logic s_axis_frame_tuser, s_axis_frame_tlast, s_axis_frame_tvalid, s_axis_frame_tready;

	logic [7:0] axis_frame_b2d_tdata;
	logic axis_frame_b2d_tuser, axis_frame_b2d_tlast, axis_frame_b2d_tvalid, axis_frame_b2d_tready;

	logic [48:0] s_axis_ctl_tdata;
	logic s_axis_ctl_tvalid, s_axis_ctl_tready;

	logic in_frame;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_FIFO;
			in_frame <= 1'b0;
		end else begin
			state <= state_next;

			if(state != ST_WRITE_FRAME) begin
				if(s_axis_tvalid) begin
					in_frame <= ~s_axis_tlast;
				end
			end else begin
				if(s_axis_tvalid & s_axis_tlast) begin
					in_frame <= 1'b0;
				end
			end
		end
	end

	always_comb begin
		state_next = state;

		s_axis_frame_tdata = s_axis_tdata;
		s_axis_frame_tuser = s_axis_tuser[49];
		s_axis_frame_tlast = s_axis_tlast;
		s_axis_frame_tvalid = 1'b0;

		s_axis_ctl_tdata = s_axis_tuser[48:0];
		s_axis_ctl_tvalid = 1'b0;

		case(state)
			ST_WAIT_FIFO: begin
				if(s_axis_frame_tready & s_axis_ctl_tready) begin
					state_next = ST_WRITE_FRAME;
				end
			end

			ST_WRITE_FRAME: begin
				if(~in_frame) begin
					s_axis_frame_tvalid = s_axis_tvalid;

					if(s_axis_tvalid) begin
						if(~s_axis_frame_tready) begin
							state_next = ST_OVERFLOW_A;
						end else if(s_axis_tlast) begin
							state_next = ST_WRITE_CTL;
						end
					end
				end
			end

			ST_WRITE_CTL: begin
				s_axis_ctl_tvalid = 1'b1;

				if(s_axis_ctl_tready) begin
					state_next = ST_WAIT_FIFO;
				end
			end

			ST_OVERFLOW_A: begin
				s_axis_frame_tlast = 1'b1;
				s_axis_frame_tvalid = 1'b1;

				if(s_axis_frame_tready) begin
					state_next = ST_OVERFLOW_B;
				end
			end

			ST_OVERFLOW_B: begin
				s_axis_ctl_tdata[1:0] = 2'b10;
				s_axis_ctl_tvalid = 1'b1;

				if(s_axis_ctl_tready) begin
					state_next = ST_WAIT_FIFO;
				end
			end

			default: begin
				state_next = ST_WAIT_FIFO;
			end
		endcase
	end

	axis_fifo
	#(
		.C_DEPTH(C_LOOP_FIFO_B_SIZE),
		.C_MEM_TYPE("distributed"),
		.C_CDC_STAGES(0),

		.C_DATA_WIDTH(8),
		.C_DEST_WIDTH(1),
		.C_USER_WIDTH(1),
		.C_ID_WIDTH(1),

		.C_HAS_STRB(0),
		.C_HAS_KEEP(0),
		.C_HAS_DEST(0),
		.C_HAS_USER(1),
		.C_HAS_ID(0),
		.C_HAS_LAST(1),

		.C_ENABLE_S_COUNT(0),
		.C_ENABLE_M_COUNT(0),
		.C_COUNT_WIDTH(1)
	)
	U0
	(
		.s_clk(clk_tx),
		.s_rst_n(rst_tx_n),

		.s_axis_tdata(axis_frame_b2d_tdata),
		.s_axis_tuser(axis_frame_b2d_tuser),
		.s_axis_tlast(axis_frame_b2d_tlast),
		.s_axis_tvalid(axis_frame_b2d_tvalid),
		.s_axis_tready(axis_frame_b2d_tready),

		.m_clk(clk_tx),

		.m_axis_tdata(m_axis_frame_tdata),
		.m_axis_tuser(m_axis_frame_tuser),
		.m_axis_tlast(m_axis_frame_tlast),
		.m_axis_tvalid(m_axis_frame_tvalid),
		.m_axis_tready(m_axis_frame_tready)
	);

	axis_fifo
	#(
		.C_DEPTH(C_LOOP_FIFO_A_SIZE),
		.C_MEM_TYPE("block"),
		.C_CDC_STAGES(2),

		.C_DATA_WIDTH(8),
		.C_DEST_WIDTH(1),
		.C_USER_WIDTH(1),
		.C_ID_WIDTH(1),

		.C_HAS_STRB(0),
		.C_HAS_KEEP(0),
		.C_HAS_DEST(0),
		.C_HAS_USER(1),
		.C_HAS_ID(0),
		.C_HAS_LAST(1),

		.C_ENABLE_S_COUNT(0),
		.C_ENABLE_M_COUNT(0),
		.C_COUNT_WIDTH(1)
	)
	U1
	(
		.s_clk(clk),
		.s_rst_n(rst_n),

		.s_axis_tdata(s_axis_frame_tdata),
		.s_axis_tuser(s_axis_frame_tuser),
		.s_axis_tlast(s_axis_frame_tlast),
		.s_axis_tvalid(s_axis_frame_tvalid),
		.s_axis_tready(s_axis_frame_tready),

		.m_clk(clk_tx),

		.m_axis_tdata(axis_frame_b2d_tdata),
		.m_axis_tuser(axis_frame_b2d_tuser),
		.m_axis_tlast(axis_frame_b2d_tlast),
		.m_axis_tvalid(axis_frame_b2d_tvalid),
		.m_axis_tready(axis_frame_b2d_tready)
	);

	axis_fifo
	#(
		.C_DEPTH(C_LOOP_FIFO_A_SIZE / 32),
		.C_MEM_TYPE("block"),
		.C_CDC_STAGES(2),

		.C_DATA_WIDTH(49),
		.C_DEST_WIDTH(1),
		.C_USER_WIDTH(1),
		.C_ID_WIDTH(1),

		.C_HAS_STRB(0),
		.C_HAS_KEEP(0),
		.C_HAS_DEST(0),
		.C_HAS_USER(0),
		.C_HAS_ID(0),
		.C_HAS_LAST(0),

		.C_ENABLE_S_COUNT(0),
		.C_ENABLE_M_COUNT(0),
		.C_COUNT_WIDTH(1)
	)
	U2
	(
		.s_clk(clk),
		.s_rst_n(rst_n),

		.s_axis_tdata(s_axis_ctl_tdata),
		.s_axis_tvalid(s_axis_ctl_tvalid),
		.s_axis_tready(s_axis_ctl_tready),

		.m_clk(clk_tx),

		.m_axis_tdata(m_axis_ctl_tdata),
		.m_axis_tvalid(m_axis_ctl_tvalid),
		.m_axis_tready(m_axis_ctl_tready)
	);
endmodule
