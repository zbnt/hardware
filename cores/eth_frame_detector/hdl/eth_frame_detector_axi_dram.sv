/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_frame_detector_axi_dram #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst_n,

	input logic read_req,
	input logic [12:0] read_addr,

	input logic write_req,
	input logic [axi_width-1:0] write_mask,
	input logic [12:0] write_addr,
	input logic [axi_width-1:0] write_data,

	output logic done,

	// MEM

	output logic mem_req,
	output logic mem_we,
	input logic mem_ack,

	output logic [10:0] mem_addr,
	output logic [30*(axi_width/32)-1:0] mem_wdata,
	input logic [30*(axi_width/32)-1:0] mem_rdata
);
	enum logic [1:0] {ST_IDLE, ST_READ_MEM, ST_WRITE_MEM} state, state_next;

	logic mem_ack_prev;
	logic mem_write_pending;
	logic [30*(axi_width/32)-1:0] write_mask_q;

	for(genvar i = 0; i < axi_width/32; ++i) begin
		always_ff @(posedge clk) begin
			if(~rst_n) begin
				write_mask_q <= '0;
				mem_wdata <= '0;
			end else begin
				if(state == ST_IDLE && write_req) begin
					write_mask_q[i*30+29:i*30] <= write_mask[i*32+29:i*32];
					mem_wdata[i*30+29:i*30] <= write_data[i*32+29:i*32];
				end else if(state == ST_READ_MEM && ~mem_ack && mem_ack_prev) begin
					mem_wdata <= (mem_wdata & write_mask_q) | (mem_rdata & ~write_mask_q);
				end
			end
		end
	end

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			mem_req <= 1'b0;
			mem_we <= 1'b0;

			mem_addr <= 11'd0;

			done <= 1'b0;
			mem_write_pending <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					if(write_req) begin
						state <= ST_READ_MEM;
						mem_we <= 1'b0;
						mem_addr <= write_addr;
						mem_req <= 1'b1;
						mem_write_pending <= 1'b1;
					end else if(read_req) begin
						state <= ST_READ_MEM;
						mem_we <= 1'b0;
						mem_addr <= read_addr;
						mem_req <= 1'b1;
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
