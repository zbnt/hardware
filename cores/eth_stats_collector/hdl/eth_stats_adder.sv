/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_stats_adder
(
	input logic clk,
	input logic rst_n,
	input logic enable,

	input logic valid,
	input logic [16:0] frame_length,
	input logic frame_good,

	output logic [63:0] total_bytes,
	output logic [63:0] total_good,
	output logic [63:0] total_bad
);
	always_ff @(posedge clk) begin
		if(~rst_n) begin
			total_bytes <= 64'd0;
			total_good <= 64'd0;
			total_bad <= 64'd0;
		end else if(valid & enable) begin
			total_bytes <= total_bytes + {47'd0, frame_length};
			total_good <= total_good + {63'd0, frame_good};
			total_bad <= total_bad + {63'd0, ~frame_good};
		end
	end
endmodule
