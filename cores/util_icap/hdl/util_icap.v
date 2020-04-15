/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_icap #(parameter C_FAMILY_TYPE = 0)
(
	input wire clk,

	input wire csib,
	input wire rdwrb,
	input wire [31:0] i,
	output wire [31:0] o,

	output wire avail,
	output wire prdone,
	output wire prerror
);
	if(~C_FAMILY_TYPE) begin
		ICAPE2 U0
		(
			.CLK(clk),

			.CSIB(csib),
			.RDWRB(rdwrb),
			.I(i),
			.O(o)
		);
	end else begin
		ICAPE3 U0
		(
			.CLK(clk),

			.CSIB(csib),
			.RDWRB(rdwrb),
			.I(i),
			.O(o),

			.AVAIL(avail),
			.PRDONE(prdone),
			.PRERROR(prerror)
		);
	end
endmodule
