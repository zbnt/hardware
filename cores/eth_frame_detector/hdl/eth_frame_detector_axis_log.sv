/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axis_log #(parameter C_AXIS_LOG_ENABLE = 1, parameter C_AXIS_LOG_WIDTH = 64, parameter C_DIRECTION_ID = 65)
(
	input logic clk,
	input logic rst_n,

	input logic [15:0] log_id,
	output logic [63:0] overflow_count,

	input logic [63:0] current_time,

	input logic [3:0] match,
	input logic [1:0] match_id,
	input logic [4:0] match_ext_num,
	input logic [127:0] match_ext_data,

	// M_AXIS_LOG

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output logic m_axis_log_tlast,
	output logic m_axis_log_tvalid,
	input logic m_axis_log_tready
);
	if(C_AXIS_LOG_ENABLE) begin
		localparam C_TX_BUFFER_WIDTH = 224;
		localparam C_TX_COUNT_WIDTH = $clog2(((C_TX_BUFFER_WIDTH + C_AXIS_LOG_WIDTH - 1)/C_AXIS_LOG_WIDTH) * (C_AXIS_LOG_WIDTH/8) + 1);

		logic tx_enable;
		logic [C_TX_COUNT_WIDTH-1:0] tx_count;
		logic [C_TX_COUNT_WIDTH-1:0] tx_limit;
		logic [C_TX_BUFFER_WIDTH-1:0] tx_buffer;

		logic [1:0] last_match_id;

		always_ff @(posedge clk) begin
			if(~rst_n) begin
				tx_enable <= 1'b0;
				tx_count <= '0;
				tx_limit <= '0;
				tx_buffer <= '0;
				overflow_count <= 64'd0;
				last_match_id <= 2'd0;
			end else begin
				if(~tx_enable) begin
					if(last_match_id != match_id) begin
						tx_enable <= 1'b1;
						tx_buffer <= {match_ext_data, 11'd0, match_ext_num, 4'd0, match, C_DIRECTION_ID[7:0], 16'd4 + {3'd0, match_ext_num}, log_id, 32'h02425AFF};
						tx_count <= C_AXIS_LOG_WIDTH[C_TX_COUNT_WIDTH+2:3];
						tx_limit <= 16'd12 + {3'd0, match_ext_num};
					end
				end else begin
					if(last_match_id != match_id) begin
						overflow_count <= overflow_count + 64'd1;
					end

					if(m_axis_log_tready) begin
						if(C_AXIS_LOG_WIDTH < C_TX_BUFFER_WIDTH) begin
							tx_buffer <= {'0, tx_buffer[C_TX_BUFFER_WIDTH-1:C_AXIS_LOG_WIDTH]};
						end

						if(m_axis_log_tlast) begin
							tx_enable <= 1'b0;
						end else begin
							tx_count <= tx_count + C_AXIS_LOG_WIDTH[C_TX_COUNT_WIDTH+2:3];
						end
					end
				end

				last_match_id <= match_id;
			end
		end

		always_comb begin
			m_axis_log_tdata = (C_AXIS_LOG_WIDTH <= C_TX_BUFFER_WIDTH) ? tx_buffer[C_AXIS_LOG_WIDTH-1:0] : {'0, tx_buffer};
			m_axis_log_tlast = (tx_count >= tx_limit);
			m_axis_log_tvalid = tx_enable;
		end
	end else begin
		always_comb begin
			overflow_count = 64'd0;
			m_axis_log_tdata = '0;
			m_axis_log_tlast = 1'b0;
			m_axis_log_tvalid = 1'b0;
		end
	end
endmodule
