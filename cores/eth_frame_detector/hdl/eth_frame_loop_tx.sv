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
	input logic s_axis_frame_tlast,
	input logic s_axis_frame_tvalid,
	output logic s_axis_frame_tready,

	// S_AXIS_CTL

	input logic [55:0] s_axis_ctl_tdata, // {IP_CSUM, CSUM_VAL, CSUM_POS, DROP_FRAME, FCS_INVALID}
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
	logic [14:0] checksum_tr_pos;
	logic corrupt_fcs;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_CTL;

			count <= 16'd0;
			checksum_ip <= 16'd0;
			checksum_tr <= 16'd0;
			checksum_tr_pos <= 15'd0;
			corrupt_fcs <= 1'b0;

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
						checksum_ip <= s_axis_ctl_tdata[48:33];
						checksum_tr <= s_axis_ctl_tdata[32:17];
						checksum_tr_pos <= s_axis_ctl_tdata[16:2];
						corrupt_fcs <= s_axis_ctl_tdata[0];

						s_axis_ctl_tready <= 1'b0;
					end
				end

				ST_TX_FRAME: begin
					if(m_axis_tready & m_axis_tvalid) begin
						count <= count + 16'd1;

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
			if(checksum_ip != 16'd0 && count[15:1] == 15'd12) begin
				if(~count[0]) begin
					m_axis_tdata = checksum_ip[15:8];
				end else begin
					m_axis_tdata = checksum_ip[7:0];
				end
			end else if(checksum_tr != 16'd0 && count[15:1] == checksum_tr_pos) begin
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
endmodule
