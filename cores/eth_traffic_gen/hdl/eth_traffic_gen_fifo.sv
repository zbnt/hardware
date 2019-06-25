/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_fifo
(
	input logic clk,
	input logic rst,
	input logic fifo_rst,

	input logic trigger,
	output logic ready,

	input logic frame_delay_src,
	input logic frame_delay_wen,
	input logic [31:0] frame_delay_req,
	output logic [10:0] frame_delay_avail,

	input logic payload_size_src,
	input logic payload_size_wen,
	input logic [15:0] payload_size_req,
	output logic [10:0] payload_size_avail,

	output logic [31:0] frame_delay,
	output logic [15:0] payload_size
);
	logic got_frame_delay, got_payload_size;

	logic tfifo_full, tfifo_empty, tfifo_written, tfifo_read;
	logic [31:0] tfifo_out;

	logic sfifo_full, sfifo_empty, sfifo_written, sfifo_read;
	logic [15:0] sfifo_out;

	always_ff @(posedge clk) begin
		if(rst) begin
			got_frame_delay <= 1'b0;
			frame_delay <= 32'd0;

			got_payload_size <= 1'b0;
			payload_size <= 16'd0;
		end else begin
			if(~frame_delay_src) begin
				if(frame_delay_wen) begin
					got_frame_delay <= 1'b1;
					frame_delay <= frame_delay_req;
				end
			end else if(trigger) begin
				got_frame_delay <= 1'b0;
				frame_delay <= 32'd0;
			end else if(tfifo_read) begin
				got_frame_delay <= 1'b1;
				frame_delay <= tfifo_out;
			end

			if(~payload_size_src) begin
				if(payload_size_wen) begin
					got_payload_size <= 1'b1;
					payload_size <= frame_delay_req;
				end
			end else if(trigger) begin
				got_payload_size <= 1'b0;
				payload_size <= 32'd0;
			end else if(sfifo_read) begin
				got_payload_size <= 1'b1;
				payload_size <= sfifo_out;
			end
		end
	end

	always_comb begin
		ready = got_frame_delay & got_payload_size;
	end

	interframe_times_fifo U0
	(
		.clk(clk),
		.rst(rst | fifo_rst),

		.wr_ack(tfifo_written),
		.valid(tfifo_read),

		.full(tfifo_full),
		.din(frame_delay_req),
		.wr_en(frame_delay_src & frame_delay_wen & ~tfifo_full),

		.empty(tfifo_empty),
		.dout(tfifo_out),
		.rd_en(((frame_delay_src & ~got_frame_delay) | tfifo_full) & ~tfifo_empty)
	);

	payload_sizes_fifo U1
	(
		.clk(clk),
		.rst(rst | fifo_rst),

		.wr_ack(sfifo_written),
		.valid(sfifo_read),

		.full(sfifo_full),
		.din(payload_size_req),
		.wr_en(payload_size_src & payload_size_wen & ~sfifo_full),

		.empty(sfifo_empty),
		.dout(sfifo_out),
		.rd_en(((payload_size_src & ~got_payload_size) | sfifo_full) & ~sfifo_empty)
	);

	counter #(11) U2
	(
		.clk(clk),
		.rst(rst | fifo_rst),

		.up(tfifo_written),
		.down(tfifo_read),

		.count(frame_delay_avail)
	);

	counter #(11) U3
	(
		.clk(clk),
		.rst(rst | fifo_rst),

		.up(sfifo_written),
		.down(sfifo_read),

		.count(payload_size_avail)
	);
endmodule
