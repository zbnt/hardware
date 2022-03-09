/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module alu
(
	input logic clk,
	input logic rst_n,

	input logic [7:0] opcode,
	input logic [63:0] a,
	input logic [63:0] b,

	output logic [7:0] res,
	output logic res_valid
);
	logic [63:0] lfsr_value;

	// Latency: 1 cycle
	logic [63:0] result_add, result_set, result_mask;
	logic [1:0] result_s2_src;

	// Latency: 2 cycles
	logic [63:0] result_s2;

	// Latency: 8 cycles
	logic [63:0] result_s2_s3, result_mult;
	logic [7:0] opcode_s3;

	// Latency: 9 cycles
	logic [63:0] result_s3;
	logic [7:0] mask_s3;

	// Latency: 10 cycles
	logic [63:0] result_s4;
	logic [7:0] mask_s4;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			result_add <= 64'd0;
			result_set <= 64'd0;
			result_mask <= 64'd0;

			result_s2_src <= 2'd0;
			result_s2 <= 64'd0;
			result_s3 <= 64'd0;
			result_s4 <= 64'd0;

			mask_s3 <= 8'd0;
			mask_s4 <= 8'd0;
		end else begin
			// Stage 1

			result_add <= a + b;

			if(~opcode[4]) begin
				result_set <= b;
			end else begin
				result_set <= lfsr_value;
			end

			case(opcode[5:4])
				2'd0: begin
					result_mask <= a & b;
				end

				2'd1: begin
					result_mask <= a | b;
				end

				2'd2: begin
					result_mask <= a ^ b;
				end

				2'd3: begin
					result_mask <= a ~^ b;
				end
			endcase

			case(opcode[3:1])
				3'd1: begin
					// set
					result_s2_src <= 2'd0;
				end

				3'd2: begin
					// mask
					result_s2_src <= 2'd1;
				end

				3'd3: begin
					// add
					result_s2_src <= 2'd2;
				end

				default: begin
					result_s2_src <= 2'd0;
				end
			endcase

			// Stage 2

			case(result_s2_src)
				2'd0: begin
					result_s2 <= result_set;
				end

				2'd1: begin
					result_s2 <= result_mask;
				end

				2'd2: begin
					result_s2 <= result_add;
				end

				default: begin
					result_s2 <= result_set;
				end
			endcase

			// Stage 3

			case(opcode_s3[3:1])
				3'd4: begin
					if(~opcode_s3[4]) begin
						result_s3 <= result_mult;
					end else begin
						case(opcode_s3[7:6])
							2'd0: begin
								result_s3[7:0] <= result_mult[7:0];
							end

							2'd1: begin
								result_s3[7:0] <= result_mult[15:8];
								result_s3[15:8] <= result_mult[7:0];
							end

							2'd2: begin
								result_s3[7:0] <= result_mult[31:24];
								result_s3[15:8] <= result_mult[23:16];
								result_s3[23:16] <= result_mult[15:8];
								result_s3[31:24] <= result_mult[7:0];
							end

							2'd3: begin
								result_s3[7:0] <= result_mult[63:56];
								result_s3[15:8] <= result_mult[55:48];
								result_s3[23:16] <= result_mult[47:40];
								result_s3[31:24] <= result_mult[39:32];
								result_s3[39:32] <= result_mult[31:24];
								result_s3[47:40] <= result_mult[23:16];
								result_s3[55:48] <= result_mult[15:8];
								result_s3[63:56] <= result_mult[7:0];
							end
						endcase
					end
				end

				default: begin
					if(~opcode_s3[4]) begin
						result_s3 <= result_s2_s3;
					end else begin
						case(opcode_s3[7:6])
							2'd0: begin
								result_s3[7:0] <= result_s2_s3[7:0];
							end

							2'd1: begin
								result_s3[7:0] <= result_s2_s3[15:8];
								result_s3[15:8] <= result_s2_s3[7:0];
							end

							2'd2: begin
								result_s3[7:0] <= result_s2_s3[31:24];
								result_s3[15:8] <= result_s2_s3[23:16];
								result_s3[23:16] <= result_s2_s3[15:8];
								result_s3[31:24] <= result_s2_s3[7:0];
							end

							2'd3: begin
								result_s3[7:0] <= result_s2_s3[63:56];
								result_s3[15:8] <= result_s2_s3[55:48];
								result_s3[23:16] <= result_s2_s3[47:40];
								result_s3[31:24] <= result_s2_s3[39:32];
								result_s3[39:32] <= result_s2_s3[31:24];
								result_s3[47:40] <= result_s2_s3[23:16];
								result_s3[55:48] <= result_s2_s3[15:8];
								result_s3[63:56] <= result_s2_s3[7:0];
							end
						endcase
					end
				end
			endcase

			if(opcode_s3[3:1] > 3'd0 && opcode_s3[3:1] < 3'd5) begin
				case(opcode_s3[7:6])
					2'd0: begin
						mask_s3 <= 8'b0000_0001;
					end

					2'd1: begin
						mask_s3 <= 8'b0000_0011;
					end

					2'd2: begin
						mask_s3 <= 8'b0000_1111;
					end

					2'd3: begin
						mask_s3 <= 8'b1111_1111;
					end
				endcase
			end else begin
				mask_s3 <= 8'b0000_0000;
			end

			// Stage 4

			if(mask_s4 == 8'd0 || mask_s4 == 8'd1) begin
				result_s4 <= result_s3;
				mask_s4 <= mask_s3;
			end else begin
				result_s4 <= {8'd0, result_s4[63:8]};
				mask_s4 <= {1'b0, mask_s4[7:1]};
			end
		end
	end

	always_comb begin
		res = result_s4[7:0];
		res_valid = mask_s4[0];
	end

	multiplier #(5) U0
	(
		.clk(clk),
		.rst(~rst_n),

		.is_signed(opcode[5]),
		.a(a),
		.b(b),

		.res(result_mult)
	);

	reg_slice #(8, 5) U1
	(
		.clk(clk),
		.rst(~rst_n),
		.data_in(opcode),
		.data_out(opcode_s3)
	);

	reg_slice #(64, 3) U2
	(
		.clk(clk),
		.rst(~rst_n),
		.data_in(result_s2),
		.data_out(result_s2_s3)
	);

	lfsr_prng #(64, 4, 63, 62, 60, 59) U3
	(
		.clk(clk),
		.rst(~rst_n),
		.enable(1'b1),
		.value_in(64'd0),
		.value_out(lfsr_value)
	);
endmodule
