/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module checksum_calculator #(parameter C_NUM_VALUES = 2)
(
	input logic clk,
	input logic rst,

	input logic trigger,

	input logic [(16*C_NUM_VALUES)-1:0] values,
	output logic [15:0] checksum
);
	logic [$clog2(C_NUM_VALUES+1)-1:0] count;
	logic [(16*(C_NUM_VALUES-1))-1:0] queue;
	logic [15:0] current_sum;
	logic [16:0] adder;

	always_ff @(posedge clk) begin
		if(rst) begin
			count <= '0;
			queue <= '0;
			checksum <= '0;
			current_sum <= '0;
		end else begin
			if(count == 0) begin
				if(trigger) begin
					count <= 'd1;
					queue <= values[(16*C_NUM_VALUES)-1:16];
					current_sum <= {1'b0, values[15:0]};
				end
			end else if(count != C_NUM_VALUES) begin
				count <= count + 'd1;
				current_sum <= adder[15:0] + {15'd0, adder[16]};

				if(C_NUM_VALUES != 2) begin
					queue <= {16'd0, queue[(16*(C_NUM_VALUES-1))-1:16]};
				end
			end

			if(current_sum == '1) begin
				checksum <= '1;
			end else begin
				checksum <= ~current_sum;
			end
		end
	end

	always_comb begin
		adder = {1'b0, current_sum[15:0]} + {1'b0, queue[15:0]};
	end
endmodule
