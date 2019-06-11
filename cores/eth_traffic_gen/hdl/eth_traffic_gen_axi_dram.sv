/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axi_dram
(
	input logic clk,
	input logic rst,

	// DRAM

	output logic [10:0] mem_addr,
	output logic [7:0] mem_wdata,
	output logic mem_we,
	input logic [7:0] mem_rdata,

	// Read channel

	input logic read_req,
	input logic [11:0] read_addr,

	output logic read_ready,
	output logic read_response,
	output logic [31:0] read_value,

	// Write channel

	input logic write_req,
	input logic [11:0] write_addr,
	input logic [31:0] write_value,
	input logic [3:0] write_mask,

	output logic write_ready,
	output logic write_response
);
	enum logic [1:0] {ST_IDLE, ST_READ_MEM, ST_WRITE_MEM} state, state_next;
	logic [1:0] count, count_next;
	logic [31:0] read_value_next;

	// Store values that could change after the read_req or write_req flag goes back to 0
	logic read_pending, write_pending;
	logic [11:0] q_read_addr;
	logic [31:0] q_write_value;
	logic [3:0] q_write_mask;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			state <= ST_IDLE;
			count <= 2'd0;
			read_value <= 32'd0;

			read_pending <= 1'b0;
			write_pending <= 1'b0;

			q_read_addr <= 12'd0;
			q_write_value <= 32'd0;
			q_write_mask <= 4'd0;
		end else begin
			state <= state_next;
			count <= count_next;
			read_value <= read_value_next;

			// Store request parameters, set a pending flag in case the module is busy

			if(read_req) begin
				read_pending <= 1'b1;
				q_read_addr <= read_addr;
			end

			if(write_req) begin
				write_pending <= 1'b1;
				q_write_value <= write_value;
				q_write_mask <= write_mask;
			end

			if(read_ready) begin
				read_pending <= 1'b0;
			end

			if(write_ready) begin
				write_pending <= 1'b0;
			end
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		read_value_next = read_value;

		read_ready = 1'b0;
		read_response = 1'b1;

		write_ready = 1'b0;
		write_response = 1'b1;

		mem_addr = 11'd0;
		mem_wdata = 8'd0;
		mem_we = 1'b0;

		if(~rst) begin
			case(state)
				ST_IDLE: begin
					if(write_req | write_pending) begin
						state_next = ST_WRITE_MEM;
						count_next = 2'd0;
					end else if(read_req | read_pending) begin
						state_next = ST_READ_MEM;
						count_next = 2'd0;
					end
				end

				// Read and write operations must be split in 4, DRAM has a width of only 8 bits
				// LSB is stored in the lowest address (little endian)

				ST_READ_MEM: begin
					if(&count) begin
						state_next = ST_IDLE;
						count_next = 2'd0;
						read_ready = 1'b1;
					end else begin
						count_next = count + 2'd1;
					end

					// Discard first bit to remove the offset from the address.
					// Address validation is done in the parent module.
					mem_addr = {q_read_addr[10:2], count};

					case(count)
						2'd0: read_value_next[7:0] = mem_rdata;
						2'd1: read_value_next[15:8] = mem_rdata;
						2'd2: read_value_next[23:16] = mem_rdata;
						2'd3: read_value_next[31:24] = mem_rdata;
					endcase
				end

				// For write operations, in order to keep things simple, the module iterates
				// over all the 4 bytes, regardless of the write mask.

				ST_WRITE_MEM: begin
					if(&count) begin
						state_next = ST_IDLE;
						count_next = 2'd0;
						write_ready = 1'b1;
					end else begin
						count_next = count + 2'd1;
					end

					// Discard first bit to remove the offset from the address.
					// Address validation is done in the parent module.
					mem_addr = {write_addr[10:2], count};

					case(count)
						2'd0: begin
							mem_wdata = q_write_value[7:0];
							mem_we = q_write_mask[0];
						end

						2'd1: begin
							mem_wdata = q_write_value[15:8];
							mem_we = q_write_mask[1];
						end

						2'd2: begin
							mem_wdata = q_write_value[23:16];
							mem_we = q_write_mask[2];
						end

						2'd3: begin
							mem_wdata = q_write_value[31:24];
							mem_we = q_write_mask[3];
						end
					endcase
				end

				default: begin
					state_next = ST_IDLE;
					count_next = 2'd0;
				end
			endcase
		end
	end
endmodule
