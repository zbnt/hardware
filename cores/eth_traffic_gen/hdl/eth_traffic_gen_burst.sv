/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_traffic_gen_burst
(
	input logic clk,
	input logic rst_n,

	input logic use_burst,
	input logic [15:0] burst_on_time,
	input logic [15:0] burst_off_time,

	output logic burst_enable
);
	logic [16:0] count_ns;
	logic [15:0] count_ms;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			burst_enable <= 1'b0;
			count_ns <= 17'd0;
			count_ms <= 16'd1;
		end else begin
			if(count_ns >= 17'd124999) begin
				count_ns <= 17'd0;

				if(burst_enable) begin
					if(count_ms >= burst_on_time) begin
						burst_enable <= 1'b0;
						count_ms <= 16'd1;
					end else begin
						count_ms <= count_ms + 16'd1;
					end
				end else begin
					if(count_ms >= burst_off_time) begin
						burst_enable <= 1'b1;
						count_ms <= 16'd1;
					end else begin
						count_ms <= count_ms + 16'd1;
					end
				end
			end else begin
				count_ns <= count_ns + 17'd1;
			end
		end
	end
endmodule
