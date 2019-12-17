/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_latency_measurer_coord
(
	input logic clk,
	input logic rst,
	input logic enable,

	input logic use_broadcast,
	input logic [31:0] delay_time,
	input logic [31:0] timeout,

	input logic [15:0] psize_req,
	input logic [47:0] mac_addr_src_req,
	input logic [47:0] mac_addr_dst_req,
	input logic [31:0] ip_addr_src_req,
	input logic [31:0] ip_addr_dst_req,

	output logic [15:0] psize,

	output logic [47:0] mac_addr_src_a,
	output logic [47:0] mac_addr_dst_a,
	output logic [31:0] ip_addr_src_a,
	output logic [31:0] ip_addr_dst_a,

	output logic [47:0] mac_addr_src_b,
	output logic [47:0] mac_addr_dst_b,
	output logic [31:0] ip_addr_src_b,
	output logic [31:0] ip_addr_dst_b,

	input logic [15:0] main_rx_ping_id,
	input logic [15:0] loop_rx_ping_id,

	output logic main_tx_trigger,
	output logic loop_tx_trigger,
	input logic main_tx_begin,
	input logic loop_tx_begin,

	output logic done,
	output logic [63:0] ping_count,
	output logic [31:0] ping_time,
	output logic [31:0] pong_time,
	output logic [63:0] pings_lost,
	output logic [63:0] pongs_lost
);
	enum logic [2:0] {ST_START, ST_WAIT_PING_TX, ST_PING, ST_WAIT_PONG_TX, ST_PONG, ST_DELAY} state, state_next;
	logic main_tx_trigger_next, loop_tx_trigger_next;

	logic done_next;
	logic [31:0] count, count_next, ping_time_next, pong_time_next;
	logic [63:0] ping_count_next, pings_lost_next, pongs_lost_next;

	logic [15:0] psize_next;
	logic [47:0] mac_addr_src_a_next, mac_addr_dst_a_next, mac_addr_src_b_next, mac_addr_dst_b_next;
	logic [31:0] ip_addr_src_a_next, ip_addr_dst_a_next, ip_addr_src_b_next, ip_addr_dst_b_next;

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_START;

			main_tx_trigger <= 1'b0;
			loop_tx_trigger <= 1'b0;

			done <= 1'b0;
			count <= 32'd1;
			ping_time <= 32'd0;
			pong_time <= 32'd0;

			psize <= 16'd0;
			mac_addr_src_a <= 48'd0;
			mac_addr_dst_a <= 48'd0;
			mac_addr_src_b <= 48'd0;
			mac_addr_dst_b <= 48'd0;
			ip_addr_src_a <= 32'd0;
			ip_addr_dst_a <= 32'd0;
			ip_addr_src_b <= 32'd0;
			ip_addr_dst_b <= 32'd0;

			ping_count <= 64'd0;
			pings_lost <= 64'd0;
			pongs_lost <= 64'd0;
		end else begin
			state <= state_next;

			main_tx_trigger <= main_tx_trigger_next;
			loop_tx_trigger <= loop_tx_trigger_next;

			done <= done_next;
			count <= count_next;
			ping_time <= ping_time_next;
			pong_time <= pong_time_next;

			psize <= psize_next;
			mac_addr_src_a <= mac_addr_src_a_next;
			mac_addr_dst_a <= mac_addr_dst_a_next;
			mac_addr_src_b <= mac_addr_src_b_next;
			mac_addr_dst_b <= mac_addr_dst_b_next;
			ip_addr_src_a <= ip_addr_src_a_next;
			ip_addr_dst_a <= ip_addr_dst_a_next;
			ip_addr_src_b <= ip_addr_src_b_next;
			ip_addr_dst_b <= ip_addr_dst_b_next;

			ping_count <= ping_count_next;
			pings_lost <= pings_lost_next;
			pongs_lost <= pongs_lost_next;
		end
	end

	always_comb begin
		state_next = state;

		done_next = 1'b0;
		count_next = count;
		ping_time_next = ping_time;
		pong_time_next = pong_time;

		psize_next = psize;
		mac_addr_src_a_next = mac_addr_src_a;
		mac_addr_dst_a_next = mac_addr_dst_a;
		mac_addr_src_b_next = mac_addr_src_b;
		mac_addr_dst_b_next = mac_addr_dst_b;
		ip_addr_src_a_next = ip_addr_src_a;
		ip_addr_dst_a_next = ip_addr_dst_a;
		ip_addr_src_b_next = ip_addr_src_b;
		ip_addr_dst_b_next = ip_addr_dst_b;

		ping_count_next = ping_count;
		pings_lost_next = pings_lost;
		pongs_lost_next = pongs_lost;

		main_tx_trigger_next = 1'b0;
		loop_tx_trigger_next = 1'b0;

		if(~rst) begin
			count_next = count + 32'd1;

			case(state)
				ST_START: begin
					count_next = 32'd1;

					if(enable) begin
						state_next = ST_WAIT_PING_TX;
						main_tx_trigger_next = 1'b1;

						psize_next = psize_req;
						mac_addr_src_a_next = mac_addr_src_req;
						mac_addr_src_b_next = mac_addr_dst_req;
						ip_addr_src_a_next = ip_addr_src_req;
						ip_addr_src_b_next = ip_addr_dst_req;

						if(use_broadcast) begin
							mac_addr_dst_a_next = 48'hFFFFFFFFFFFF;
							mac_addr_dst_b_next = 48'hFFFFFFFFFFFF;
							ip_addr_dst_a_next = 32'hFFFFFFFF;
							ip_addr_dst_b_next = 32'hFFFFFFFF;
						end else begin
							mac_addr_dst_a_next = mac_addr_dst_req;
							mac_addr_dst_b_next = mac_addr_src_req;
							ip_addr_dst_a_next = ip_addr_dst_req;
							ip_addr_dst_b_next = ip_addr_src_req;
						end
					end
				end

				ST_WAIT_PING_TX: begin
					if(main_tx_begin) begin
						state_next = ST_PING;
						count_next = 32'd1;
					end
				end

				ST_PING: begin
					if(loop_rx_ping_id == ping_count[15:0]) begin
						// Ping received in loopback interface
						state_next = ST_WAIT_PONG_TX;
						count_next = 32'd1;
						ping_time_next = count;
						loop_tx_trigger_next = 1'b1;
					end else if(count >= timeout) begin
						// Ping not received
						state_next = ST_DELAY;
						count_next = 32'd1;

						done_next = 1'b1;
						ping_time_next = '1;
						pong_time_next = '1;

						pings_lost_next = pings_lost + 64'd1;
						ping_count_next = ping_count + 64'd1;
					end
				end

				ST_WAIT_PONG_TX: begin
					if(loop_tx_begin) begin
						state_next = ST_PONG;
						count_next = 32'd1;
					end
				end

				ST_PONG: begin
					if(main_rx_ping_id == ping_count[15:0]) begin
						// Pong received in main interface
						state_next = ST_DELAY;
						count_next = 32'd1;

						done_next = 1'b1;
						pong_time_next = count;

						ping_count_next = ping_count + 64'd1;
					end else if(count >= timeout) begin
						// Pong not received
						state_next = ST_DELAY;
						count_next = 32'd1;

						done_next = 1'b1;
						pong_time_next = '1;

						pongs_lost_next = pongs_lost + 64'd1;
						ping_count_next = ping_count + 64'd1;
					end
				end

				ST_DELAY: begin
					if(count >= delay_time) begin
						state_next = ST_START;
						count_next = 32'd0;
					end
				end

				default: begin
					state_next = ST_START;
				end
			endcase
		end
	end
endmodule
