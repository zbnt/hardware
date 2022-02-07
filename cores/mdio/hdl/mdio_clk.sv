/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module mdio_clk
(
	input logic clk,
	input logic rst_n,

	output logic mdio_en,
	output logic mdc
);
	logic count;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			count <= 1'b0;
			mdio_en <= 1'b0;
			mdc <= 1'b0;
		end else begin
			count <= ~count;
			mdio_en <= ~mdc & count;

			if(count) begin
				mdc <= ~mdc;
			end
		end
	end
endmodule
