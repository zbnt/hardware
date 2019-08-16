/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_counter_rx
(
	input logic clk,
	input logic rst_n,

	input logic axis_rx_tvalid,
	input logic axis_rx_tlast,
	input logic axis_rx_tuser,

	output logic [15:0] frame_bytes,
	output logic frame_good,
	output logic valid
);
	logic in_frame;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			in_frame <= 1'b0;

			frame_bytes <= 16'd0;
			frame_good <= 1'b1;
			valid <= 1'b0;
		end else begin
			if(in_frame) begin
				if(axis_rx_tvalid) begin
					if(axis_rx_tlast) begin
						valid <= 1'b1;
						in_frame <= 1'b0;
					end

					if(axis_rx_tuser) begin
						frame_good <= 1'b0;
					end

					if(~&frame_bytes) begin
						frame_bytes <= frame_bytes + 16'd1;
					end
				end
			end else begin
				if(axis_rx_tvalid) begin
					in_frame <= 1'b1;

					frame_bytes <= 16'd0;
					frame_good <= 1'b1;
				end

				valid <= 1'b0;
			end
		end
	end
endmodule
