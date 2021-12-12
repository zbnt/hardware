/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_axis_log #(parameter C_AXIS_LOG_ENABLE = 1, parameter C_AXIS_LOG_WIDTH = 64)
(
	input logic clk,
	input logic rst_n,

	input logic trigger,
	input logic [15:0] log_id,
	output logic [63:0] overflow_count,

	input logic [63:0] current_time,
	input logic [63:0] ping_count,
	input logic [31:0] ping_time,
	input logic [31:0] pong_time,
	input logic [63:0] pings_lost,
	input logic [63:0] pongs_lost,

	// M_AXIS_LOG

	output logic [C_AXIS_LOG_WIDTH-1:0] m_axis_log_tdata,
	output logic m_axis_log_tlast,
	output logic m_axis_log_tvalid,
	input logic m_axis_log_tready
);
	if(C_AXIS_LOG_ENABLE) begin
		localparam C_TX_COUNT_WIDTH = (C_AXIS_LOG_WIDTH < 384) ? $clog2(384/C_AXIS_LOG_WIDTH) : 1;
		localparam C_TX_COUNT_MAX = (C_AXIS_LOG_WIDTH < 384) ? (384/C_AXIS_LOG_WIDTH - 1) : 0;

		logic tx_enable;
		logic [383:0] tx_buffer;
		logic [C_TX_COUNT_WIDTH-1:0] tx_count;

		always_ff @(posedge clk) begin
			if(~rst_n) begin
				tx_enable <= 1'b0;
				tx_buffer <= 384'd0;
				tx_count <= '0;
				overflow_count <= 64'd0;
			end else begin
				if(~tx_enable) begin
					if(trigger) begin
						tx_enable <= 1'b1;
						tx_buffer <= {pongs_lost, pings_lost, pong_time, ping_time, ping_count, current_time, 16'd40, log_id, 32'h02425AFF};
						tx_count <= '0;
					end
				end else begin
					if(trigger) begin
						overflow_count <= overflow_count + 64'd1;
					end

					if(m_axis_log_tready) begin
						if(C_AXIS_LOG_WIDTH < 384) begin
							tx_buffer <= {'0, tx_buffer[383:C_AXIS_LOG_WIDTH]};
						end

						if(m_axis_log_tlast) begin
							tx_enable <= 1'b0;
						end else begin
							tx_count <= tx_count + 'd1;
						end
					end
				end
			end
		end

		always_comb begin
			m_axis_log_tdata = (C_AXIS_LOG_WIDTH <= 384) ? tx_buffer[C_AXIS_LOG_WIDTH-1:0] : {'0, tx_buffer};
			m_axis_log_tlast = (tx_count == C_TX_COUNT_MAX);
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
