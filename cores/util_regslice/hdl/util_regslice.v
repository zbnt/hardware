/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_regslice #(parameter C_WIDTH = 32, parameter C_NUM_STAGES = 2)
(
	input wire clk,
	input wire rst_n,

	input wire [C_WIDTH-1:0] data_in,
	output wire [C_WIDTH-1:0] data_out
);
	reg_slice #(C_WIDTH, C_NUM_STAGES) U0
	(
		.clk(clk),
		.rst(~rst_n),
		.data_in(data_in),
		.data_out(data_out)
	);
endmodule
