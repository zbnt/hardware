/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_iobuf #(parameter C_WIDTH = 1)
(
	input wire [C_WIDTH-1:0] signal_o,
	input wire [C_WIDTH-1:0] signal_t,
	output wire [C_WIDTH-1:0] signal_i,

	inout wire [C_WIDTH-1:0] signal_io
);
	for(genvar i = 0; i < C_WIDTH; i = i + 1) begin
		IOBUF
		(
			.O(signal_i[i]),
			.IO(signal_io[i]),
			.I(signal_o[i]),
			.T(signal_t[i])
		);
	end
endmodule
