/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mdio_fsm
(
	input logic clk,
	input logic rst_n,

	input logic enable,

	input logic trigger,
	input logic operation,
	input logic [9:0] addr,
	input logic [15:0] data_in,

	output logic done,
	output logic [15:0] data_out,

	// MDIO

	input logic mdio_i,
	output logic mdio_o,
	output logic mdio_t
);
	enum logic [2:0] {ST_IDLE, ST_PREAMBLE, ST_START, ST_OPERATION, ST_ADDR, ST_TURNAROUND, ST_DATA, ST_DONE} state, state_next;

	logic mdio_o_next, mdio_t_next;

	logic [15:0] data_out_next;
	logic done_next;

	logic operation_q, operation_q_next;
	logic [9:0] addr_q, addr_q_next;

	logic [4:0] count, count_next;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			mdio_o <= 1'b0;
			mdio_t <= 1'b1;

			done <= 1'b0;
			data_out <= 16'd0;

			operation_q <= 1'b0;
			addr_q <= 10'd0;

			count <= 5'd0;
		end else if(enable) begin
			state <= state_next;

			mdio_o <= mdio_o_next;
			mdio_t <= mdio_t_next;

			done <= done_next;
			data_out <= data_out_next;

			operation_q <= operation_q_next;
			addr_q <= addr_q_next;

			count <= count_next;
		end
	end

	always_comb begin
		state_next = state;

		mdio_o_next = mdio_o;
		mdio_t_next = mdio_t;

		done_next = 1'b0;
		data_out_next = data_out;

		operation_q_next = operation_q;
		addr_q_next = addr_q;

		count_next = 5'd0;

		case(state)
			ST_IDLE: begin
				if(trigger) begin
					state_next = ST_PREAMBLE;

					mdio_o_next = 1'b1;
					mdio_t_next = 1'b0;

					data_out_next = data_in;
					operation_q_next = operation;
					addr_q_next = addr;
				end
			end

			ST_PREAMBLE: begin
				if(&count) begin
					state_next = ST_START;
				end

				count_next = count + 5'd1;
			end

			ST_START: begin
				if(count[0]) begin
					state_next = ST_OPERATION;
					count_next = 5'd0;
					mdio_o_next = ~mdio_o;
				end else begin
					count_next = 5'd1;
					mdio_o_next = 1'b0;
				end
			end

			ST_OPERATION: begin
				if(count[0]) begin
					state_next = ST_ADDR;
					count_next = 5'd0;
					mdio_o_next = ~mdio_o;
				end else begin
					count_next = 5'd1;
					mdio_o_next = ~operation_q;
				end
			end

			ST_ADDR: begin
				mdio_o_next = addr_q[9];
				addr_q_next = {addr_q[8:0], 1'b0};

				if(count == 5'd9) begin
					state_next = ST_TURNAROUND;
					count_next = 5'd0;
				end else begin
					count_next = count + 5'd1;
				end
			end

			ST_TURNAROUND: begin
				if(count[0]) begin
					state_next = ST_DATA;
					count_next = 5'd0;
					mdio_o_next = 1'b0;
				end else begin
					count_next = 5'd1;
					mdio_o_next = 1'b1;
					mdio_t_next = ~operation_q;
				end
			end

			ST_DATA: begin
				count_next = count + 5'd1;

				if(operation_q) begin
					mdio_t_next = 1'b0;
					mdio_o_next = data_out[15];
					data_out_next = {data_out[14:0], 1'b0};

					if(&count[3:0]) begin
						state_next = ST_DONE;
						done_next = 1'b1;
					end
				end else begin
					mdio_t_next = 1'b1;
					mdio_o_next = data_out[15];
					data_out_next = {data_out[14:0], mdio_i};

					if(count == 5'd16) begin
						state_next = ST_DONE;
						done_next = 1'b1;
					end
				end
			end

			ST_DONE: begin
				state_next = ST_IDLE;
				mdio_t_next = 1'b1;
			end
		endcase
	end
endmodule
