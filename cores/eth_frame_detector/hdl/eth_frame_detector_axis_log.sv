/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axis_log #(parameter C_AXIS_LOG_WIDTH = 64, parameter C_DIRECTION_ID = 65, parameter C_NUM_SCRIPTS = 4)
(
	input logic clk,
	input logic rst_n,

	input logic [15:0] log_id,

	// M_AXIS_LOG

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output logic m_axis_log_tlast,
	output logic m_axis_log_tvalid,
	input logic m_axis_log_tready,

	// S_AXIS_FRAME

	input logic [C_AXIS_LOG_WIDTH-1:0] s_axis_frame_tdata,
	input logic s_axis_frame_tvalid,
	output logic s_axis_frame_tready,

	// S_AXIS_CTL

	input logic [C_NUM_SCRIPTS+79:0] s_axis_ctl_tdata, // {C_NUM_SCRIPTS * {MATCHED}, SIZE, TIMESTAMP}
	input logic s_axis_ctl_tvalid,
	output logic s_axis_ctl_tready
);
	localparam C_TX_BUFFER_WIDTH = 176;
	localparam C_TX_HEADER_SIZE = ((C_TX_BUFFER_WIDTH + C_AXIS_LOG_WIDTH - 64 - 1)/C_AXIS_LOG_WIDTH) * (C_AXIS_LOG_WIDTH/8);
	localparam C_TX_MAX_COUNT = ((C_TX_BUFFER_WIDTH + C_AXIS_LOG_WIDTH - 1)/C_AXIS_LOG_WIDTH) - 1;
	localparam C_TX_COUNT_WIDTH = $clog2(C_TX_MAX_COUNT + 1);

	enum logic [1:0] {ST_WAIT_CTL, ST_TX_HEADER, ST_TX_FRAME, ST_DROP_FRAME} state;

	logic [C_TX_BUFFER_WIDTH-1:0] tx_buffer;
	logic [C_TX_COUNT_WIDTH-1:0] tx_count;
	logic [15:0] frame_size;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_CTL;

			tx_count <= '0;
			tx_buffer <= '0;
			frame_size <= 16'd0;

			s_axis_ctl_tready <= 1'b0;
		end else begin
			case(state)
				ST_WAIT_CTL: begin
					s_axis_ctl_tready <= 1'b1;

					if(s_axis_ctl_tvalid & s_axis_ctl_tready) begin
						frame_size <= s_axis_ctl_tdata[79:64];

						if(s_axis_ctl_tdata[C_NUM_SCRIPTS+79:80] != '0) begin
							state <= ST_TX_HEADER;
							s_axis_ctl_tready <= 1'b0;

							tx_count <= '0;
							tx_buffer[31:0] <= 32'h02425AFF;
							tx_buffer[47:32] <= log_id;
							tx_buffer[63:48] <= C_TX_HEADER_SIZE[15:0] + s_axis_ctl_tdata[79:64];
							tx_buffer[127:64] <= s_axis_ctl_tdata[63:0];
							tx_buffer[135:128] <= C_DIRECTION_ID[7:0];
							tx_buffer[143:136] <= C_AXIS_LOG_WIDTH[10:3];
							tx_buffer[159:144] <= s_axis_ctl_tdata[79:64];
							tx_buffer[C_NUM_SCRIPTS+159:160] <= s_axis_ctl_tdata[C_NUM_SCRIPTS+79:80];
						end else if(s_axis_ctl_tdata[79:64] != 16'd0) begin
							state <= ST_DROP_FRAME;
							s_axis_ctl_tready <= 1'b0;
						end
					end
				end

				ST_TX_HEADER: begin
					if(m_axis_log_tready) begin
						if(C_AXIS_LOG_WIDTH < C_TX_BUFFER_WIDTH) begin
							tx_buffer <= {'0, tx_buffer[C_TX_BUFFER_WIDTH-1:C_AXIS_LOG_WIDTH]};
						end

						if(tx_count == C_TX_MAX_COUNT) begin
							if(frame_size != 16'd0) begin
								state <= ST_TX_FRAME;
							end else begin
								state <= ST_WAIT_CTL;
							end
						end else begin
							tx_count <= tx_count + 'd1;
						end
					end
				end

				ST_TX_FRAME: begin
					if(m_axis_log_tvalid & m_axis_log_tready) begin
						frame_size <= frame_size - C_AXIS_LOG_WIDTH[18:3];

						if(frame_size <= C_AXIS_LOG_WIDTH[18:3]) begin
							state <= ST_WAIT_CTL;
						end
					end
				end

				ST_DROP_FRAME: begin
					if(s_axis_frame_tvalid) begin
						frame_size <= frame_size - C_AXIS_LOG_WIDTH[18:3];

						if(frame_size <= C_AXIS_LOG_WIDTH[18:3]) begin
							state <= ST_WAIT_CTL;
						end
					end
				end
			endcase
		end
	end

	always_comb begin
		case(state)
			ST_TX_HEADER: begin
				m_axis_log_tdata = (C_AXIS_LOG_WIDTH <= C_TX_BUFFER_WIDTH) ? tx_buffer[C_AXIS_LOG_WIDTH-1:0] : {'0, tx_buffer};
				m_axis_log_tlast = (tx_count == C_TX_MAX_COUNT && frame_size == 16'd0);
				m_axis_log_tvalid = 1'b1;
				s_axis_frame_tready = 1'b0;
			end

			ST_TX_FRAME: begin
				m_axis_log_tdata = s_axis_frame_tdata;
				m_axis_log_tlast = (frame_size <= C_AXIS_LOG_WIDTH[18:3]);
				m_axis_log_tvalid = s_axis_frame_tvalid;
				s_axis_frame_tready = m_axis_log_tready;
			end

			ST_DROP_FRAME: begin
				m_axis_log_tdata = '0;
				m_axis_log_tlast = 1'b0;
				m_axis_log_tvalid = 1'b0;
				s_axis_frame_tready = 1'b1;
			end

			default: begin
				m_axis_log_tdata = '0;
				m_axis_log_tlast = 1'b0;
				m_axis_log_tvalid = 1'b0;
				s_axis_frame_tready = 1'b0;
			end
		endcase
	end
endmodule
