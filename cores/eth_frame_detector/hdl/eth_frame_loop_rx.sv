/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_rx
(
	input logic clk,
	input logic rst_n,

	input logic mode,

	// M_AXIS_FRAME

	output logic [7:0] m_axis_frame_tdata,
	output logic m_axis_frame_tuser,
	output logic m_axis_frame_tlast,
	output logic m_axis_frame_tvalid,
	input logic m_axis_frame_tready,

	// M_AXIS_CSUM

	output logic [31:0] m_axis_csum_tdata,
	output logic m_axis_csum_tvalid,
	input logic m_axis_csum_tready,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic [1:0] s_axis_tuser,
	input logic s_axis_tlast,
	input logic s_axis_tvalid
);
	enum logic [1:0] {ST_WAIT_FIFO, ST_TX_MODE_0, ST_TX_MODE_1, ST_OVERFLOW} state, state_next;

	logic [15:0] checksum, checksum_pos;
	logic checksum_done;
	logic checksum_written, checksum_written_next;
	logic frame_modified, frame_modified_next;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_FIFO;
			checksum_written <= 1'b0;
			frame_modified <= 1'b0;
		end else begin
			state <= state_next;
			checksum_written <= checksum_written_next;
			frame_modified <= frame_modified_next;
		end
	end

	always_comb begin
		state_next = state;
		checksum_written_next = checksum_written;
		frame_modified_next = frame_modified;

		m_axis_frame_tdata = 8'd0;
		m_axis_frame_tuser = 1'b0;
		m_axis_frame_tlast = 1'b0;
		m_axis_frame_tvalid = 1'b0;

		m_axis_csum_tdata = 32'd0;
		m_axis_csum_tvalid = 1'b0;

		case(state)
			ST_WAIT_FIFO: begin
				if(m_axis_frame_tready & m_axis_csum_tready) begin
					m_axis_frame_tdata = s_axis_tdata;
					m_axis_frame_tuser = s_axis_tuser[0];
					m_axis_frame_tlast = s_axis_tlast;
					m_axis_frame_tvalid = s_axis_tvalid;

					if(s_axis_tvalid) begin
						if(~mode) begin
							state_next = ST_TX_MODE_0;
							m_axis_csum_tvalid = 1'b1;
							checksum_written_next = 1'b1;
							frame_modified_next = s_axis_tuser[1];
						end else begin
							state_next = ST_TX_MODE_1;
							checksum_written_next = 1'b0;
						end
					end
				end
			end

			ST_TX_MODE_0: begin
				m_axis_frame_tdata = s_axis_tdata;
				m_axis_frame_tuser = s_axis_tuser[0];
				m_axis_frame_tlast = s_axis_tlast;
				m_axis_frame_tvalid = s_axis_tvalid;

				if(~m_axis_frame_tready) begin
					state_next = ST_OVERFLOW;
				end else if(s_axis_tvalid & s_axis_tlast) begin
					state_next = ST_WAIT_FIFO;
				end
			end

			ST_TX_MODE_1: begin
				m_axis_frame_tdata = s_axis_tdata;
				m_axis_frame_tuser = s_axis_tuser[0];
				m_axis_frame_tlast = s_axis_tlast;
				m_axis_frame_tvalid = s_axis_tvalid;

				m_axis_csum_tdata = {checksum, checksum_pos[15:1], frame_modified};
				m_axis_csum_tvalid = checksum_done;

				if(s_axis_tuser[1]) begin
					frame_modified_next = 1'b1;
				end

				if(checksum_done) begin
					checksum_written_next = 1'b1;
				end

				if(~m_axis_frame_tready) begin
					state_next = ST_OVERFLOW;
				end else if(~s_axis_tvalid) begin
					state_next = ST_WAIT_FIFO;
				end
			end

			ST_OVERFLOW: begin
				m_axis_frame_tdata = 8'd0;
				m_axis_frame_tuser = 1'b1;
				m_axis_frame_tlast = 1'b1;
				m_axis_frame_tvalid = checksum_written;

				m_axis_csum_tvalid = ~checksum_written;

				if(m_axis_csum_tready) begin
					checksum_written_next = 1'b1;
				end

				if(m_axis_frame_tvalid & m_axis_frame_tready) begin
					state_next = ST_WAIT_FIFO;
				end
			end
		endcase
	end

	transport_checksum U0
	(
		.clk(clk),
		.rst_n(rst_n),

		.checksum(checksum),
		.checksum_orig(),
		.checksum_pos(checksum_pos),
		.checksum_done(checksum_done),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid)
	);
endmodule
