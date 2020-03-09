/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module multiplier #(parameter C_LATENCY = 8)
(
	input logic clk,
	input logic rst,

	input logic is_signed,
	input logic [63:0] a,
	input logic [63:0] b,

	output logic [63:0] res
);
	logic [63:0] a_q, b_q;
	logic [63:0] ab_q[0:1], ab;
	logic [31:0] p[0:9], p_q[0:2];

	logic a_sign, b_sign, is_signed_q;

	always_ff @(posedge clk) begin
		// Stage 1: Prepare operands

		if(rst) begin
			a_q <= 64'd0;
			b_q <= 64'd0;
		end else begin
			if(is_signed & a[63]) begin
				a_q <= -a;
			end else begin
				a_q <= a;
			end

			if(is_signed & b[63]) begin
				b_q <= -b;
			end else begin
				b_q <= b;
			end
		end

		// Stage 2: Execute multiplication

		p[0] <= a_q[15:0]  * b_q[15:0];
		p[1] <= a_q[31:16] * b_q[15:0];
		p[2] <= a_q[47:32] * b_q[15:0];
		p[3] <= a_q[63:48] * b_q[15:0];

		p[4] <= a_q[15:0]  * b_q[31:16];
		p[5] <= a_q[31:16] * b_q[31:16];
		p[6] <= a_q[47:32] * b_q[31:16];

		p[7] <= a_q[15:0]  * b_q[47:32];
		p[8] <= a_q[31:16] * b_q[47:32];

		p[9] <= a_q[15:0]  * b_q[63:48];

		// Stage 3: Addition

		ab_q[0] <= {p[2], p[0]}
		         + {p[3][15:0], p[1], 16'd0}
		         + {p[6][15:0], p[4], 16'd0}
		         + {p[5], 32'd0};

		p_q[0] <= p[7];
		p_q[1] <= p[8];
		p_q[2] <= p[9];

		// Stage 4: Addition again

		ab_q[1] <= ab_q[0]
		         + {p_q[0], 32'd0}
		         + {p_q[1][15:0], 48'd0}
		         + {p_q[2][15:0], 48'd0};

		// Stage 5: Output

		if(is_signed_q & (a_sign ^ b_sign)) begin
			ab <= -ab_q[1];
		end else begin
			ab <= ab_q[1];
		end
	end

	reg_slice #(3, 4) U0
	(
		.clk(clk),
		.rst(rst),
		.data_in({b[63], a[63], is_signed}),
		.data_out({b_sign, a_sign, is_signed_q})
	);

	if(C_LATENCY > 5) begin
		reg_slice #(64, C_LATENCY - 5) U1
		(
			.clk(clk),
			.rst(rst),
			.data_in(ab),
			.data_out(res)
		);
	end else begin
		always_comb begin
			res = ab;
		end
	end
endmodule
