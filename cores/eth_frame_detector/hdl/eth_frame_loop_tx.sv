/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_loop_tx
(
	input logic clk,
	input logic rst_n,

	// S_AXIS_FRAME

	input logic [7:0] s_axis_frame_tdata,
	input logic s_axis_frame_tuser,
	input logic s_axis_frame_tlast,
	input logic s_axis_frame_tvalid,
	output logic s_axis_frame_tready,

	// S_AXIS_CTL

	input logic [48:0] s_axis_ctl_tdata, // {UPDATE_FCS, IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, CORRUPT_FRAME}
	input logic s_axis_ctl_tvalid,
	output logic s_axis_ctl_tready,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_CTL, ST_TX_FRAME, ST_DROP_FRAME} state;

	logic [15:0] checksum_tr, checksum_ip, count;
	logic [13:0] checksum_tr_pos;
	logic corrupt_fcs;

	logic [31:0] fcs_state, fcs_next;
	logic fcs_update;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_CTL;

			count <= 16'd0;
			checksum_ip <= 16'd0;
			checksum_tr <= 16'd0;
			checksum_tr_pos <= 14'd0;
			corrupt_fcs <= 1'b0;

			fcs_state <= '1;
			fcs_update <= 1'b0;

			s_axis_ctl_tready <= 1'b0;
		end else begin
			case(state)
				ST_WAIT_CTL: begin
					s_axis_ctl_tready <= 1'b1;

					if(s_axis_ctl_tready & s_axis_ctl_tvalid) begin
						if(~s_axis_ctl_tdata[1]) begin
							state <= ST_TX_FRAME;
						end else begin
							state <= ST_DROP_FRAME;
						end

						count <= 16'd0;

						fcs_state <= '1;
						fcs_update <= s_axis_ctl_tdata[48];

						checksum_ip <= s_axis_ctl_tdata[47:32];
						checksum_tr <= s_axis_ctl_tdata[31:16];
						checksum_tr_pos <= s_axis_ctl_tdata[15:2];
						corrupt_fcs <= s_axis_ctl_tdata[0];

						s_axis_ctl_tready <= 1'b0;
					end
				end

				ST_TX_FRAME: begin
					if(m_axis_tready & m_axis_tvalid) begin
						count <= count + 16'd1;

						if(fcs_update) begin
							if(~s_axis_frame_tuser) begin
								fcs_state <= fcs_next;
							end else begin
								fcs_state <= {8'hFF, fcs_state[31:8]};
							end
						end

						if(m_axis_tlast) begin
							state <= ST_WAIT_CTL;
						end
					end
				end

				ST_DROP_FRAME: begin
					if(s_axis_frame_tready & s_axis_frame_tvalid & s_axis_frame_tlast) begin
						state <= ST_WAIT_CTL;
					end
				end

				default: begin
					state <= ST_WAIT_CTL;
				end
			endcase
		end
	end

	always_comb begin
		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tuser = 1'b0;
		m_axis_tvalid = 1'b0;
		s_axis_frame_tready = 1'b0;

		if(state == ST_TX_FRAME) begin
			if(fcs_update & s_axis_frame_tuser) begin
				m_axis_tdata = ~fcs_state[7:0];
			end else if(checksum_ip != 16'd0 && count[15:1] == 15'd12) begin
				if(~count[0]) begin
					m_axis_tdata = checksum_ip[15:8];
				end else begin
					m_axis_tdata = checksum_ip[7:0];
				end
			end else if(checksum_tr != 16'd0 && count[15:1] == {1'b0, checksum_tr_pos}) begin
				if(~count[0]) begin
					m_axis_tdata = checksum_tr[15:8];
				end else begin
					m_axis_tdata = checksum_tr[7:0];
				end
			end else begin
				m_axis_tdata = s_axis_frame_tdata;
			end

			m_axis_tlast = s_axis_frame_tlast;
			m_axis_tuser = corrupt_fcs & s_axis_frame_tlast;
			m_axis_tvalid = s_axis_frame_tvalid;
			s_axis_frame_tready = m_axis_tready;
		end else if(state == ST_DROP_FRAME) begin
			s_axis_frame_tready = 1'b1;
		end
	end

	lfsr
	#(
		.LFSR_WIDTH(32),
		.LFSR_POLY(32'h4c11db7),
		.LFSR_CONFIG("GALOIS"),
		.LFSR_FEED_FORWARD(0),
		.REVERSE(1),
		.DATA_WIDTH(8),
		.STYLE("AUTO")
	)
	U0
	(
		.data_in(m_axis_tdata),
		.state_in(fcs_state),
		.data_out(),
		.state_out(fcs_next)
	);
endmodule
