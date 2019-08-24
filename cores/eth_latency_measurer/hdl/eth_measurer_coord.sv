/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_coord
(
	input logic clk,
	input logic rst,
	input logic enable,

	input logic [15:0] psize_req,
	input logic [31:0] delay_time,
	input logic [31:0] timeout,

	output logic [15:0] psize,

	output logic [63:0] ping_id,
	input logic [63:0] main_rx_ping_id,
	input logic [63:0] loop_rx_ping_id,

	output logic main_tx_trigger,
	output logic loop_tx_trigger,
	input logic main_tx_begin,
	input logic loop_tx_begin,

	output logic done,
	output logic [31:0] ping_time,
	output logic [31:0] pong_time,
	output logic [63:0] ping_pongs_good,
	output logic [63:0] pings_lost,
	output logic [63:0] pongs_lost
);
	enum logic [2:0] {ST_DELAY, ST_WAIT_PING_TX, ST_PING, ST_WAIT_PONG_TX, ST_PONG} state, state_next;

	logic done_next;
	logic [15:0] psize_next;
	logic [63:0] ping_id_next;
	logic [31:0] count, count_next, ping_time_next, pong_time_next;
	logic [63:0] ping_pongs_good_next, pings_lost_next, pongs_lost_next;

	logic main_tx_trigger_next, loop_tx_trigger_next;

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_DELAY;
			ping_id <= 64'd0;

			main_tx_trigger <= 1'b0;
			loop_tx_trigger <= 1'b0;

			done <= 1'b0;
			count <= 32'd1;
			psize <= 16'd46;
			ping_time <= 32'd0;
			pong_time <= 32'd0;

			ping_pongs_good <= 64'd0;
			pings_lost <= 64'd0;
			pongs_lost <= 64'd0;
		end else begin
			state <= state_next;
			ping_id <= ping_id_next;

			main_tx_trigger <= main_tx_trigger_next;
			loop_tx_trigger <= loop_tx_trigger_next;

			done <= done_next;
			count <= count_next;
			psize <= psize_next;
			ping_time <= ping_time_next;
			pong_time <= pong_time_next;

			ping_pongs_good <= ping_pongs_good_next;
			pings_lost <= pings_lost_next;
			pongs_lost <= pongs_lost_next;
		end
	end

	always_comb begin
		state_next = state;
		ping_id_next = ping_id;

		done_next = 1'b0;
		count_next = count;
		psize_next = psize;
		ping_time_next = ping_time;
		pong_time_next = pong_time;

		ping_pongs_good_next = ping_pongs_good;
		pings_lost_next = pings_lost;
		pongs_lost_next = pongs_lost;

		main_tx_trigger_next = 1'b0;
		loop_tx_trigger_next = 1'b0;

		if(~rst) begin
			count_next = count + 32'd1;

			case(state)
				ST_DELAY: begin
					if(enable) begin
						if(count >= delay_time) begin
							state_next = ST_WAIT_PING_TX;
							count_next = 32'd0;
							psize_next = psize_req;
							main_tx_trigger_next = 1'b1;
						end
					end else begin
						count_next = 32'd1;
					end
				end

				ST_WAIT_PING_TX: begin
					if(main_tx_begin) begin
						state_next = ST_PING;
						count_next = 32'd1;
					end
				end

				ST_PING: begin
					if(loop_rx_ping_id == ping_id) begin
						// Ping received in loopback interface
						state_next = ST_WAIT_PONG_TX;
						count_next = 32'd1;
						ping_time_next = count;
						loop_tx_trigger_next = 1'b1;
					end else if(count >= timeout) begin
						// Ping not received
						state_next = ST_DELAY;
						count_next = 32'd0;

						done_next = 1'b1;
						ping_time_next = '1;
						pong_time_next = '1;

						pings_lost_next = pings_lost + 64'd1;
					end
				end

				ST_WAIT_PONG_TX: begin
					if(loop_tx_begin) begin
						state_next = ST_PONG;
						count_next = 32'd1;
					end
				end

				ST_PONG: begin
					if(main_rx_ping_id == ping_id) begin
						// Pong received in main interface
						state_next = ST_DELAY;
						count_next = 32'd0;

						done_next = 1'b1;
						ping_id_next = ping_id + 64'd1;
						pong_time_next = count;

						ping_pongs_good_next = ping_pongs_good + 64'd1;
					end else if(count >= timeout) begin
						// Pong not received
						state_next = ST_DELAY;
						count_next = 32'd0;

						done_next = 1'b1;
						ping_id_next = ping_id + 64'd1;
						pong_time_next = '1;

						pongs_lost_next = pongs_lost + 64'd1;
					end
				end

				default: begin
					state_next = ST_DELAY;
				end
			endcase
		end
	end
endmodule
