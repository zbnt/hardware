/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_axis #(parameter axi_width = 32)
(
	input logic clk,
	input logic rst,
	input logic rst_fcount,

	// Status

	output logic [1:0] tx_state,

	// Config

	input logic enable,
	input logic [15:0] frame_size,
	input logic [31:0] frame_delay,

	input logic lfsr_seed_req,
	input logic [7:0] lfsr_seed_val,

	// MEM_FRAME

	output logic [10-$clog2(axi_width/8):0] mem_frame_addr,
	input logic [axi_width-1:0] mem_frame_rdata,

	// MEM_PATTERN

	output logic [10-$clog2(axi_width/8):0] mem_pattern_addr,
	input logic [axi_width-1:0] mem_pattern_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tuser,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_ENABLE, ST_SEND_DATA, ST_FRAME_DELAY} state, state_next;
	logic [47:0] fcount, fcount_next, fcount_sr, fcount_sr_next;
	logic [31:0] count, count_next;
	logic [15:0] fsize, fsize_next;

	logic [7:0] m_axis_tdata_next;
	logic m_axis_tlast_next;
	logic m_axis_tvalid_next;

	logic [7:0] prng_val;
	logic prng_enable;

	logic [axi_width-1:0] pqueue, pqueue_next;
	logic [axi_width-1:0] fqueue, fqueue_next;

	pcg8 U0
	(
		.clk(clk),
		.rst(rst | lfsr_seed_req),
		.enable(prng_enable),
		.seed(prng_seed),
		.value(prng_val)
	);

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_WAIT_ENABLE;
			count <= 32'd0;
			fsize <= 16'd0;

			fcount <= 48'd0;
			fcount_sr <= 48'd0;

			m_axis_tdata <= 8'd0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;

			pqueue <= '0;
			fqueue <= '0;
		end else begin
			state <= state_next;
			count <= count_next;
			fsize <= fsize_next;

			fcount <= fcount_next;
			fcount_sr <= fcount_sr_next;

			m_axis_tdata <= m_axis_tdata_next;
			m_axis_tlast <= m_axis_tlast_next;
			m_axis_tvalid <= m_axis_tvalid_next;

			pqueue <= pqueue_next;
			fqueue <= fqueue_next;
		end
	end

	always_comb begin
		state_next = state;
		count_next = count;
		fsize_next = fsize;

		fcount_next = fcount;
		fcount_sr_next = fcount_sr;

		m_axis_tdata_next = 8'd0;
		m_axis_tlast_next = 1'b0;
		m_axis_tvalid_next = 1'b0;
		m_axis_tuser = 1'b0;

		prng_enable = 1'b0;

		pqueue_next = pqueue;
		fqueue_next = fqueue;

		tx_state = state;

		mem_frame_addr = count[10:$clog2(axi_width/8)];
		mem_pattern_addr = count[10:$clog2(axi_width/8)];

		if(~rst) begin
			case(state)
				ST_WAIT_ENABLE: begin
					m_axis_tdata_next = 8'd0;
					m_axis_tlast_next = 1'b0;
					m_axis_tvalid_next = 1'b0;

					pqueue_next = {1'd0, mem_pattern_rdata[axi_width-1:1]};
					fqueue_next = {8'd0, mem_frame_rdata[axi_width-1:8]};

					if(rst_fcount) begin
						fcount_next = 48'd0;
						fcount_sr_next = 48'd0;
					end else begin
						fcount_sr_next = fcount;
					end

					if(enable) begin
						state_next = ST_SEND_DATA;
						fsize_next = frame_size;
						count_next = 32'd2;

						m_axis_tdata_next = mem_pattern_rdata[0] ? prng_val[7:0] : mem_frame_rdata[7:0];
						m_axis_tvalid_next = 1'b1;
						prng_enable = mem_pattern_rdata[0];
					end
				end

				ST_SEND_DATA: begin
					m_axis_tdata_next = m_axis_tdata;
					m_axis_tlast_next = (count == fsize);
					m_axis_tvalid_next = 1'b1;

					if(m_axis_tready) begin
						case(pqueue[1:0])
							2'd0: m_axis_tdata_next = fqueue[7:0];
							2'd1: m_axis_tdata_next = prng_val;
							2'd2: m_axis_tdata_next = fcount_sr[7:0];
							2'd3: m_axis_tdata_next = fcount_sr[7:0];
						endcase

						prng_enable = ~pqueue[1] & pqueue[0];

						if(pqueue[1:0] == 2'd2) begin
							fcount_sr_next = {fcount_sr[7:0], fcount_sr[47:8]};
						end else begin
							fcount_sr_next = fcount;
						end

						if(count == fsize) begin
							state_next = ST_FRAME_DELAY;
							count_next = 32'd2;
						end else begin
							count_next = count + 32'd1;
						end

						if(count >= 32'd2047) begin
							pqueue_next = {(axi_width/8){2'b01}};
						end else if(count[$clog2(axi_width/8)-1:0] == '0) begin
							pqueue_next = mem_pattern_rdata;
						end else begin
							pqueue_next = {2'd0, pqueue[axi_width-1:2]};
						end

						if(count[$clog2(axi_width/8)-1:0] == '0) begin
							fqueue_next = mem_frame_rdata;
						end else begin
							fqueue_next = {8'd0, fqueue[axi_width-1:8]};
						end
					end
				end

				ST_FRAME_DELAY: begin
					m_axis_tdata_next = 8'd0;
					m_axis_tlast_next = 1'b0;
					m_axis_tvalid_next = 1'b0;

					count_next = count + 32'd1;

					if(count >= frame_delay && count >= 32'd12) begin
						state_next = ST_WAIT_ENABLE;
						count_next = 32'd0;
						fcount_next = fcount + 48'd1;
					end
				end
			endcase
		end
	end
endmodule
