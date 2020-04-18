/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_cdc_array_single #(parameter C_WIDTH = 1, parameter C_NUM_STAGES = 4)
(
	input wire clk_src,
	input wire [C_WIDTH-1:0] data_src,

	input wire clk_dst,
	output wire [C_WIDTH-1:0] data_dst
);
	xpm_cdc_array_single
	#(
		.DEST_SYNC_FF(C_NUM_STAGES),
		.WIDTH(C_WIDTH)
	)
	U0
	(
		.src_clk(clk_src),
		.src_in(data_src),

		.dest_clk(clk_dst),
		.dest_out(data_dst)
	);
endmodule
