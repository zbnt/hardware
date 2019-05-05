/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_coord #(parameter timeout = 32'd12500000)
(
	input logic clk,
	input logic rst,
	input logic enable,

	input logic [15:0] psize_req,
	input logic [31:0] delay_time,

	input logic main_rx_end,
	input logic loop_rx_end,

	output logic [15:0] psize,
	output logic main_tx_trigger,
	output logic loop_tx_trigger,
	output logic main_rx_timeout,
	output logic loop_rx_timeout
);
	enum logic [1:0] {ST_WAIT, ST_PING, ST_PONG} state, state_next;
	logic [31:0] count, count_next;
	logic [15:0] psize_next;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= ST_WAIT;
			count <= 32'd0;
			psize <= 16'd46;
		end else begin
			state <= state_next;
			count <= count_next;
			psize <= psize_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		psize_next = psize;

		main_tx_trigger = (~rst && state == ST_PING && count == 32'd0);
		loop_tx_trigger = (~rst && state == ST_PONG && count == 32'd0);

		main_rx_timeout = 1'b0;
		loop_rx_timeout = 1'b0;

		if(~rst) begin
			count_next = count + 32'd1;

			case(state)
				ST_WAIT: begin
					if(enable) begin
						if(delay_time == 32'd0 || count >= delay_time - 32'd1) begin
							state_next = ST_PING;
							count_next = 32'd0;
							psize_next = psize_req;
						end
					end else begin
						count_next = 32'd0;
					end
				end

				ST_PING: begin
					if(loop_rx_end) begin
						state_next = ST_PONG;
						count_next = 32'd0;
					end else if(timeout != '0 && count >= timeout - 32'd1) begin
						state_next = ST_WAIT;
						count_next = 32'd0;
						loop_rx_timeout = 1'b1;
					end
				end

				ST_PONG: begin
					if(main_rx_end) begin
						state_next = ST_WAIT;
						count_next = 32'd0;
					end else if(timeout != '0 && count >= timeout - 32'd1) begin
						state_next = ST_WAIT;
						count_next = 32'd0;
						main_rx_timeout = 1'b1;
					end
				end

				default: begin
					state_next = ST_WAIT;
				end
			endcase
		end
	end
endmodule
