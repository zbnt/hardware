/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_timer
(
	input logic clk,
	input logic rst,

	input logic fifo_read,
	output logic [63:0] fifo_out,

	input logic main_tx_begin,
	input logic main_rx_end,
	input logic main_rx_timeout,

	input logic loop_tx_begin,
	input logic loop_rx_end,
	input logic loop_rx_timeout
);
	logic fifo_full, fifo_empty;
	logic fifo_write, fifo_write_next;

	logic [31:0] timer, timer_next;
	logic [31:0] time_ping, time_ping_next;
	logic [31:0] time_pong, time_pong_next;

	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			timer <= 32'd0;
			time_ping <= 32'd0;
			time_pong <= 32'd0;
			fifo_write <= 1'b0;
		end else begin
			timer <= timer_next;
			time_ping <= time_ping_next;
			time_pong <= time_pong_next;
			fifo_write <= fifo_write_next;
		end
	end

	always_comb begin
		timer_next = timer;
		time_ping_next = time_ping;
		time_pong_next = time_pong;
		fifo_write_next = 1'b0;

		if(~rst) begin
			timer_next = timer + 32'd1;

			if(main_tx_begin | loop_tx_begin) begin
				timer_next = 32'd2;
			end else if(loop_rx_end) begin
				time_ping_next = timer;
			end else if(loop_rx_timeout) begin
				time_ping_next = 32'hFFFFFFFF;
				time_pong_next = 32'hFFFFFFFF;
				fifo_write_next = 1'b1;
			end else if(main_rx_end) begin
				time_pong_next = timer;
			end else if(main_rx_timeout) begin
				time_pong_next = 32'hFFFFFFFF;
				fifo_write_next = 1'b1;
			end
		end
	end

	eth_times_fifo U0
	(
		.clk(clk),
		.rst(rst),

		.full(fifo_full),
		.din({time_pong, time_ping}),
		.wr_en(fifo_write & ~fifo_full),

		.empty(fifo_empty),
		.dout(fifo_out),
		.rd_en(~fifo_empty & (fifo_read | fifo_full))
	);
endmodule

