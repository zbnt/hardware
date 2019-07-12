/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axis
(
	input logic clk,
	input logic rst,

	// Status

	output logic tx_begin,
	output logic tx_busy,
	output logic [1:0] tx_state,

	// Config

	input logic enable,
	input logic fifo_ready,
	input logic [11:0] headers_size,
	input logic [15:0] payload_size,
	input logic [31:0] frame_delay,

	// MEM

	output logic [10:0] mem_addr,
	input logic [7:0] mem_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_SEND_HEADERS, ST_SEND_PAYLOAD, ST_FRAME_DELAY} state, state_next;
	logic [31:0] count, count_next;

	logic [10:0] mem_addr_next;
	logic [63:0] lfsr_val;

	logic [11:0] hsize, hsize_next;
	logic [15:0] psize, psize_next;
	logic [31:0] fdelay, fdelay_next;

	lfsr_64 U0
	(
		.clk(clk),
		.rst(rst),
		.enable(m_axis_tready && count[2:0] == 3'd7),
		.value(lfsr_val)
	);

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_SEND_HEADERS;
			count <= 32'd0;
			mem_addr <= 11'd0;

			hsize <= 12'd0;
			psize <= 16'd0;
			fdelay <= 32'd0;
		end else begin
			state <= state_next;
			count <= count_next;
			mem_addr <= mem_addr_next;

			hsize <= hsize_next;
			psize <= psize_next;
			fdelay <= fdelay_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		mem_addr_next = mem_addr;

		hsize_next = hsize;
		psize_next = psize;
		fdelay_next = fdelay;

		m_axis_tdata = 8'd0;
		m_axis_tlast = 1'b0;
		m_axis_tkeep = 1'b1;
		m_axis_tvalid = 1'b1;

		tx_begin = 1'b0;
		tx_busy = (state == ST_SEND_HEADERS || state == ST_SEND_PAYLOAD);
		tx_state = state;

		if(~rst) begin
			case(state)
				ST_SEND_HEADERS: begin
					m_axis_tdata = mem_rdata;

					if((enable & fifo_ready) || mem_addr != 11'd0) begin
						if(m_axis_tready) begin
							if(&mem_addr || mem_addr >= hsize - 12'd1) begin
								if(psize != 16'd0) begin
									state_next = ST_SEND_PAYLOAD;
									count_next = 32'd1;
								end else if(fdelay == 16'd0) begin
									count_next = 32'd0;
									m_axis_tlast = 1'b1;
								end else begin
									state_next = ST_FRAME_DELAY;
									count_next = 32'd1;
								end

								mem_addr_next = 11'd0;
							end else begin
								mem_addr_next = mem_addr + 11'd1;
							end

							if(mem_addr == '0) begin
								tx_begin = 1'b1;

								hsize_next = headers_size;
								psize_next = payload_size;
								fdelay_next = frame_delay;
							end
						end
					end else begin
						m_axis_tvalid = 1'b0;
					end
				end

				ST_SEND_PAYLOAD: begin
					case(count[2:0])
						3'd0: m_axis_tdata = lfsr_val[7:0];
						3'd1: m_axis_tdata = lfsr_val[15:8];
						3'd2: m_axis_tdata = lfsr_val[23:16];
						3'd3: m_axis_tdata = lfsr_val[31:24];
						3'd4: m_axis_tdata = lfsr_val[39:32];
						3'd5: m_axis_tdata = lfsr_val[47:40];
						3'd6: m_axis_tdata = lfsr_val[55:48];
						3'd7: m_axis_tdata = lfsr_val[63:56];
					endcase

					if(m_axis_tready) begin
						if(count[15:0] >= psize) begin
							count_next = 32'd0;
							m_axis_tlast = 1'b1;

							if(fdelay == 32'd0) begin
								state_next = ST_SEND_HEADERS;
							end else begin
								state_next = ST_FRAME_DELAY;
								count_next = 32'd1;
							end
						end else begin
							count_next = count + 32'd1;
						end
					end
				end

				ST_FRAME_DELAY: begin
					m_axis_tvalid = 1'b0;
					count_next = count + 32'd1;

					if(count >= fdelay) begin
						state_next = ST_SEND_HEADERS;
					end
				end

				default: begin
					state_next = ST_SEND_HEADERS;
					m_axis_tvalid = 1'b0;
				end
			endcase
		end
	end
endmodule
