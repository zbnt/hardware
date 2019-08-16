/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axis #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst,

	// Status

	output logic tx_busy,
	output logic [1:0] tx_state,

	// Config

	input logic enable,
	input logic [11:0] headers_size,
	input logic [15:0] payload_size,
	input logic [31:0] frame_delay,

	// MEM

	output logic [10:0] mem_addr,
	input logic [axi_width-1:0] mem_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_ENABLE, ST_SEND_HEADERS, ST_SEND_PAYLOAD, ST_FRAME_DELAY} state, state_next;
	logic [31:0] count, count_next;
	logic [10:0] hsize, hsize_next;
	logic [15:0] psize, psize_next;

	logic [63:0] lfsr_val;
	logic [63:0] lfsr_queue, lfsr_queue_next;
	logic [7:0] lfsr_queue_idx, lfsr_queue_idx_next;

	logic [axi_width-1:0] mem_queue, mem_queue_next;
	logic [(axi_width/8)-1:0] mem_queue_idx, mem_queue_idx_next;

	lfsr_64 U0
	(
		.clk(clk),
		.rst(rst),
		.enable(m_axis_tready && lfsr_queue_idx[0]),
		.value(lfsr_val)
	);

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_WAIT_ENABLE;
			count <= 32'd0;

			hsize <= 11'd0;
			psize <= 16'd0;

			lfsr_queue <= 64'd0;
			lfsr_queue_idx <= 8'd0;

			mem_queue <= '0;
			mem_queue_idx <= '0;
		end else begin
			state <= state_next;
			count <= count_next;

			hsize <= hsize_next;
			psize <= psize_next;

			lfsr_queue <= lfsr_queue_next;
			lfsr_queue_idx <= lfsr_queue_idx;

			mem_queue <= mem_queue_next;
			mem_queue_idx <= mem_queue_idx_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;

		mem_addr = count[10:0];
		hsize_next = hsize;
		psize_next = psize;

		lfsr_queue_next = lfsr_queue;
		lfsr_queue_idx_next = lfsr_queue_idx;

		mem_queue_next = mem_queue;
		mem_queue_idx_next = mem_queue_idx;

		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tkeep = 1'b1;
		m_axis_tvalid = 1'b1;

		tx_busy = (state == ST_SEND_HEADERS || state == ST_SEND_PAYLOAD);
		tx_state = state;

		if(~rst) begin
			case(state)
				ST_WAIT_ENABLE: begin
					m_axis_tvalid = 1'b0;

					if(enable) begin
						state_next = ST_SEND_HEADERS;
						hsize_next = headers_size - 12'd1;
						count_next = 32'd0;

						mem_queue_next = mem_rdata;
						mem_queue_idx_next = {1'b1, {(axi_width/8 - 2){1'b0}}};
					end
				end

				ST_SEND_HEADERS: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = mem_queue[7:0];

					if(m_axis_tready) begin
						if(count >= hsize) begin
							if(count + payload_size < 32'd59) begin
								state_next = ST_SEND_PAYLOAD;

								count_next = 32'd0;
								psize_next = 16'd59 - count - payload_size;

								lfsr_queue_next = lfsr_val;
								lfsr_queue_idx_next = 8'b1000_0000;
							end else if(payload_size == 16'd0) begin
								state_next = ST_FRAME_DELAY;
								count_next = 32'd1;
								m_axis_tlast = 1'b1;
							end else begin
								state_next = ST_SEND_PAYLOAD;

								count_next = 32'd0;
								psize_next = payload_size - 16'd1;

								lfsr_queue_next = lfsr_val;
								lfsr_queue_idx_next = 8'b1000_0000;
							end
						end else begin
							mem_queue_idx_next = {mem_queue_idx[0], mem_queue_idx[(axi_width/8)-1:1]};
							count_next = count + 32'd1;

							if(mem_queue_idx[0]) begin
								mem_queue_next = mem_rdata;
							end else begin
								mem_queue_next = {8'd0, mem_queue[axi_width-1:8]};
							end
						end
					end
				end

				ST_SEND_PAYLOAD: begin
					m_axis_tvalid = 1'b1;
					m_axis_tdata = lfsr_queue[7:0];

					if(m_axis_tready) begin
						if(count >= psize) begin
							state_next = ST_FRAME_DELAY;
							count_next = 32'd0;
							m_axis_tlast = 1'b1;
						end else begin
							lfsr_queue_idx_next = {lfsr_queue_idx[0], lfsr_queue_idx[7:1]};
							count_next = count + 32'd1;

							if(lfsr_queue_idx[0]) begin
								lfsr_queue_next = lfsr_val;
							end else begin
								lfsr_queue_next = {8'd0, lfsr_queue[63:8]};
							end
						end
					end
				end

				ST_FRAME_DELAY: begin
					m_axis_tvalid = 1'b0;
					count_next = count + 32'd1;

					if(count >= frame_delay) begin
						state_next = enable ? ST_SEND_HEADERS : ST_WAIT_ENABLE;
					end
				end
			endcase
		end
	end
endmodule
