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

	output logic [1:0] tx_state,

	// Config

	input logic enable,
	input logic [11:0] frame_size,
	input logic [31:0] frame_delay,

	input logic lfsr_seed_req,
	input logic [7:0] lfsr_seed_val,

	// MEM_FRAME

	output logic [10-$clog2(axi_width/8):0] mem_frame_addr,
	input logic [axi_width-1:0] mem_frame_rdata,

	// MEM_PATTERN

	output logic [7-$clog2(axi_width/8):0] mem_pattern_addr,
	input logic [axi_width-1:0] mem_pattern_rdata,

	// M_AXIS

	output logic [7:0] m_axis_tdata,
	output logic m_axis_tkeep,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	enum logic [1:0] {ST_WAIT_ENABLE, ST_SEND_DATA, ST_FRAME_DELAY} state, state_next;
	logic [31:0] count, count_next;
	logic [11:0] fsize, fsize_next;

	logic [7:0] m_axis_tdata_next;
	logic m_axis_tlast_next;
	logic m_axis_tvalid_next;

	logic [7:0] lfsr_val;

	logic [axi_width-1:0] pqueue, pqueue_next;
	logic [axi_width-1:0] fqueue, fqueue_next;

	lfsr #(8, 4, 7, 5, 4, 3) U0
	(
		.clk(clk),
		.rst(rst | lfsr_seed_req),
		.enable(m_axis_tready),
		.value_in(lfsr_seed_val),
		.value_out(lfsr_val)
	);

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= ST_WAIT_ENABLE;
			count <= 32'd0;
			fsize <= 12'd0;

			m_axis_tdata <= 8'd0;
			m_axis_tlast <= 1'b0;
			m_axis_tvalid <= 1'b0;

			pqueue <= '0;
			fqueue <= '0;
		end else begin
			state <= state_next;
			count <= count_next;
			fsize <= fsize_next;

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

		m_axis_tdata_next = 8'd0;
		m_axis_tlast_next = 1'b0;
		m_axis_tvalid_next = 1'b0;
		m_axis_tkeep = 1'b1;

		pqueue_next = pqueue;
		fqueue_next = fqueue;

		tx_state = state;

		mem_frame_addr = count[10:$clog2(axi_width/8)];
		mem_pattern_addr = count[7:$clog2(axi_width/8)];

		if(~rst) begin
			case(state)
				ST_WAIT_ENABLE: begin
					m_axis_tdata_next = 8'd0;
					m_axis_tlast_next = 1'b0;
					m_axis_tvalid_next = 1'b0;

					pqueue_next = {1'd0, mem_pattern_rdata[axi_width-1:1]};
					fqueue_next = {8'd0, mem_frame_rdata[axi_width-1:8]};

					if(enable) begin
						state_next = ST_SEND_DATA;
						fsize_next = frame_size;
						count_next = 32'd2;

						m_axis_tdata_next = mem_pattern_rdata[0] ? lfsr_val[7:0] : mem_frame_rdata[7:0];
						m_axis_tvalid_next = 1'b1;
					end
				end

				ST_SEND_DATA: begin
					m_axis_tdata_next = m_axis_tdata;
					m_axis_tlast_next = (count == fsize);
					m_axis_tvalid_next = 1'b1;

					if(m_axis_tready) begin
						m_axis_tdata_next = pqueue[0] ? lfsr_val : fqueue[7:0];

						if(count == fsize) begin
							state_next = ST_FRAME_DELAY;
							count_next = 32'd2;
						end else begin
							count_next = count + 32'd1;
						end

						if(count[$clog2(axi_width)-1:0] == '0) begin
							pqueue_next = mem_pattern_rdata;
						end else begin
							pqueue_next = {1'd0, pqueue[axi_width-1:1]};
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
					end
				end
			endcase
		end
	end
endmodule
