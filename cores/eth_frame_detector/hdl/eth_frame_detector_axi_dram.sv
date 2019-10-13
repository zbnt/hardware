/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi_dram #(parameter C_AXI_WIDTH = 32)
(
	input logic clk,
	input logic rst_n,

	input logic read_req,
	input logic [15:0] read_addr,

	input logic write_req,
	input logic [C_AXI_WIDTH-1:0] write_mask,
	input logic [15:0] write_addr,
	input logic [C_AXI_WIDTH-1:0] write_data,

	output logic done,

	// MEM

	output logic mem_req,
	output logic mem_we,
	input logic mem_ack,

	output logic [10:0] mem_addr,
	output logic [C_AXI_WIDTH-1:0] mem_wdata,
	input logic [C_AXI_WIDTH-1:0] mem_rdata
);
	enum logic [1:0] {ST_IDLE, ST_READ_MEM, ST_WRITE_MEM} state, state_next;

	logic mem_ack_prev;
	logic mem_write_pending;
	logic [C_AXI_WIDTH-1:0] write_mask_q;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			mem_req <= 1'b0;
			mem_we <= 1'b0;
			mem_wdata <= '0;
			write_mask_q <= '0;

			mem_addr <= 11'd0;

			done <= 1'b0;
			mem_write_pending <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					if(write_req) begin
						state <= ST_READ_MEM;
						mem_we <= 1'b0;
						mem_req <= 1'b1;
						mem_addr <= write_addr[12:2];
						mem_wdata <= write_data;
						mem_write_pending <= 1'b1;
						write_mask_q <= write_mask;
					end else if(read_req) begin
						state <= ST_READ_MEM;
						mem_we <= 1'b0;
						mem_req <= 1'b1;
						mem_addr <= read_addr[12:2];
					end

					done <= 1'b0;
				end

				ST_READ_MEM: begin
					if(mem_ack) begin
						mem_req <= 1'b0;
					end else if(mem_ack_prev) begin
						if(mem_write_pending) begin
							state <= ST_WRITE_MEM;
							mem_we <= 1'b1;
							mem_req <= 1'b1;
							mem_write_pending <= 1'b0;
							mem_wdata <= (mem_wdata & write_mask_q) | (mem_rdata & ~write_mask_q);
						end else begin
							state <= ST_IDLE;
							done <= 1'b1;
						end
					end
				end

				ST_WRITE_MEM: begin
					if(mem_ack) begin
						mem_req <= 1'b0;
					end else if(mem_ack_prev) begin
						state <= ST_IDLE;
						done <= 1'b1;
					end
				end

				default: begin
					state <= ST_IDLE;
				end
			endcase

			mem_ack_prev <= mem_ack;
		end
	end
endmodule
