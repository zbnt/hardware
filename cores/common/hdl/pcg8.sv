/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pcg8 #(parameter C_INCREMENT = 8'd77, parameter C_MULTIPLIER = 8'd141)
(
	input logic clk,
	input logic rst,
	input logic enable,
	input logic [7:0] seed,
	output logic [7:0] value
);
	logic rst_q;
	logic [1:0] occupancy;
	logic [7:0] state, word;
	logic [15:0] values;

	always_ff @(posedge clk) begin
		if(rst) begin
			state <= seed + C_INCREMENT;
			values <= 16'd0;
			occupancy <= 2'b00;
		end else if(enable | ~&occupancy) begin
			state <= state * C_MULTIPLIER + C_INCREMENT;
			values <= {{6'd0, word[7:6]} ^ word, values[15:8]};
			occupancy <= {occupancy[0], 1'b1};
		end

		word <= ((state >> ({1'b0, state[7:6]} + 3'd2)) ^ state) * 217;
	end

	always_comb begin
		value = values[7:0];
	end
endmodule
