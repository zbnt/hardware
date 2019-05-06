/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_rx #(parameter src_mac, parameter identifier)
(
	input logic clk,
	input logic rst,

	input logic clk_rx,
	input logic rst_rx,

	output logic rx_end,
	output logic [13:0] rx_bytes,
	output logic rx_good,
	output logic rx_bad,

	// S_AXIS

	input logic [7:0] s_axis_tdata,
	input logic s_axis_tkeep,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,

	// RX_STATS

	input logic [31:0] rx_stats_vector,
	input logic rx_stats_valid
);
	logic [15:0] count, count_next;
	logic [143:0] rx_buffer, rx_buffer_next;

	logic valid_frame;
	logic fifo_full, fifo_empty;
	logic [16:0] fifo_out;

	// clk_rx clock domain: reads data from the TEMAC and writes to FIFO

	always_ff @(posedge clk_rx or posedge rst_rx) begin
		if(rst_rx) begin
			count <= 16'd0;
			rx_buffer <= '0;
		end else begin
			count <= count_next;
			rx_buffer <= rx_buffer_next;
		end
	end

	always_comb begin
		count_next = count;
		rx_buffer_next = rx_buffer;
		valid_frame = 1'b0;

		if(~rst_rx & s_axis_tvalid) begin
			count_next = count + 16'd1;

			if(count <= 16'd17) begin
				rx_buffer_next = {rx_buffer[135:0], s_axis_tdata};
			end

			if(s_axis_tlast) begin
				count_next = 16'd0;

				if(rx_buffer[143:96] == 48'hFF_FF_FF_FF_FF_FF && rx_buffer[95:48] == src_mac && rx_buffer[31:0] == identifier) begin
					valid_frame = 1'b1;
				end
			end
		end
	end

	// clk clock domain: reads from the FIFO

	always_comb begin
		rx_end = 1'b0;

		rx_bytes = 14'd0;
		rx_good = 1'b0;
		rx_bad = 1'b0;

		if(~rst & ~fifo_empty) begin
			if(fifo_out[16]) begin
				rx_end = 1'b1;
			end

			if(fifo_out[0]) begin
				rx_bytes = fifo_out[15:2];
				rx_good = fifo_out[1];
				rx_bad = ~fifo_out[1];
			end
		end
	end

	// FIFO for clock domain crossing

	eth_rx_fifo U0
	(
		.rd_clk(clk),
		.wr_clk(clk_rx),
		.rst(rst_rx),

		.full(fifo_full),
		.din({valid_frame, rx_stats_vector[18:5], rx_stats_vector[0], rx_stats_valid}),
		.wr_en((valid_frame | rx_stats_valid) & ~fifo_full),

		.empty(fifo_empty),
		.dout(fifo_out),
		.rd_en(~fifo_empty & ~rst)
	);
endmodule
