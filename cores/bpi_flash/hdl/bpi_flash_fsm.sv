/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_fsm
#(
	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728,

	parameter C_ADDR_TO_CEL_TIME = 3,
	parameter C_OEL_TO_OEH_TIME = 6,
	parameter C_WEL_TO_DQ_TIME = 1,
	parameter C_DQ_TO_WEH_TIME = 6,
	parameter C_OEH_TO_DONE_TIME = 5
)
(
	input logic clk,
	input logic rst_n,

	input logic req_valid,
	output logic req_done,

	input logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] req_addr,
	input logic req_op,

	input logic [C_MEM_WIDTH-1:0] req_wdata,
	output logic [C_MEM_WIDTH-1:0] req_rdata,

	// BPI

	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] bpi_a,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_o,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_t,
	input logic [C_MEM_WIDTH-1:0] bpi_dq_i,

	output logic bpi_adv,
	output logic bpi_ce_n,
	output logic bpi_oe_n,
	output logic bpi_we_n
);
	enum logic [2:0] {ST_WAIT_REQ, ST_READ_SETUP, ST_READ_SAMPLE, ST_WRITE_SETUP, ST_WRITE_OUTPUT, ST_DONE} state;
	logic [$clog2(C_ADDR_TO_CEL_TIME | C_OEL_TO_OEH_TIME | (C_WEL_TO_DQ_TIME + C_DQ_TO_WEH_TIME) | C_OEH_TO_DONE_TIME)-1:0] count;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_WAIT_REQ;
			count <= '0;

			bpi_a <= '0;
			bpi_dq_o <= '0;
			bpi_dq_t <= '1;

			bpi_ce_n <= 1'b1;
			bpi_oe_n <= 1'b1;
			bpi_we_n <= 1'b1;
			bpi_adv <= 1'b1;

			req_done <= 1'b0;
			req_rdata <= '0;
		end else begin
			case(state)
				ST_WAIT_REQ: begin
					if(req_valid) begin
						if(~req_op) begin
							state <= ST_READ_SETUP;
						end else begin
							state <= ST_WRITE_SETUP;
						end

						count <= '0;
						bpi_a <= req_addr;
						bpi_dq_o <= req_wdata;
					end

					req_done <= 1'b0;

					bpi_ce_n <= 1'b1;
					bpi_oe_n <= 1'b1;
					bpi_we_n <= 1'b1;
					bpi_adv <= 1'b1;
				end

				ST_READ_SETUP: begin
					count <= count + 'd1;

					if(count == C_ADDR_TO_CEL_TIME - 1) begin
						state <= ST_READ_SAMPLE;
						count <= '0;

						bpi_ce_n <= 1'b0;
						bpi_oe_n <= 1'b0;
						bpi_we_n <= 1'b1;
						bpi_adv <= 1'b0;
					end
				end

				ST_READ_SAMPLE: begin
					count <= count + 'd1;

					if(count == C_OEL_TO_OEH_TIME - 1) begin
						state <= ST_DONE;
						count <= '0;

						req_rdata <= bpi_dq_i;

						bpi_ce_n <= 1'b1;
						bpi_oe_n <= 1'b1;
						bpi_we_n <= 1'b1;
						bpi_adv <= 1'b1;
					end
				end

				ST_WRITE_SETUP: begin
					count <= count + 'd1;

					if(count == C_ADDR_TO_CEL_TIME - 1) begin
						state <= ST_WRITE_OUTPUT;
						count <= '0;

						bpi_ce_n <= 1'b0;
						bpi_oe_n <= 1'b1;
						bpi_we_n <= 1'b0;
						bpi_adv <= 1'b0;
					end
				end

				ST_WRITE_OUTPUT: begin
					count <= count + 'd1;

					if(count == C_WEL_TO_DQ_TIME - 1) begin
						bpi_dq_t <= '0;
					end else if(count == C_WEL_TO_DQ_TIME + C_DQ_TO_WEH_TIME - 1) begin
						state <= ST_DONE;
						count <= '0;

						req_rdata <= '0;

						bpi_dq_t <= '1;
						bpi_ce_n <= 1'b1;
						bpi_oe_n <= 1'b1;
						bpi_we_n <= 1'b1;
						bpi_adv <= 1'b1;
					end
				end

				ST_DONE: begin
					count <= count + 'd1;
					req_done <= 1'b0;

					if(req_done) begin
						state <= ST_WAIT_REQ;
						count <= '0;
					end else if(count == C_OEH_TO_DONE_TIME - 1) begin
						req_done <= 1'b1;
					end
				end

				default: begin
					state <= ST_WAIT_REQ;
				end
			endcase
		end
	end
endmodule
