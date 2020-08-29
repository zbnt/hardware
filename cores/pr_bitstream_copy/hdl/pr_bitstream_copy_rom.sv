/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pr_bitstream_copy_rom
#(
	parameter C_AXI_ADDR_WIDTH = 32,
	parameter C_MEMORY_SIZE = 0
)
(
	output logic [C_AXI_ADDR_WIDTH-1:0] bytes_total
);
	for(genvar i = 0; i < C_AXI_ADDR_WIDTH; ++i) begin
		(* dont_touch = "true" *)
		LUT1
		#(
			.INIT({1'b0, C_MEMORY_SIZE[i]})
		)
		size_rom
		(
			.I0(1'b0),
			.O(bytes_total[i])
		);
	end
endmodule
