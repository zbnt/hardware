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
	logic [63:0] ab_q[0:2], ab;
	logic [41:0] p[0:11];
	logic [31:0] p_q[0:5];
	logic [15:0] p_q2[0:2];

	logic a_sign, b_sign, is_signed_q;

	always_ff @(posedge clk) begin
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

		for(int i = 0; i < 6; ++i) begin
			p_q[i] <= p[i + 6][31:0];
		end

		for(int i = 0; i < 3; ++i) begin
			p_q2[i] <= p_q[i + 3][15:0];
		end

		ab_q[0] <= {22'd0, p[0]}
		         + {22'd0, p[1]}
		         + {22'd0, p[2]}
		         + {6'd0, p[3], 16'd0}
		         + {6'd0, p[4], 16'd0}
		         + {6'd0, p[5], 16'd0};

		ab_q[1] <= ab_q[0]
		         + {p_q[0], 32'd0}
		         + {p_q[1], 32'd0}
		         + {p_q[2], 32'd0};

		ab_q[2] <= ab_q[1]
		         + {p_q2[0], 48'd0}
		         + {p_q2[1], 48'd0}
		         + {p_q2[2], 48'd0};

		if(is_signed_q & (a_sign ^ b_sign)) begin
			ab <= -ab_q[2];
		end else begin
			ab <= ab_q[2];
		end
	end

	for(genvar i = 0; i < 4; ++i) begin
		MULT_MACRO
		#(
			.LATENCY(3),
			.WIDTH_A(25),
			.WIDTH_B(17)
		)
		U0
		(
			.CLK(clk),
			.RST(rst),
			.CE(1'b1),

			.A({1'b0, a_q[23:0]}),
			.B({1'b0, b_q[16*i+15:16*i]}),
			.P(p[3*i])
		);

		MULT_MACRO
		#(
			.LATENCY(3),
			.WIDTH_A(25),
			.WIDTH_B(17)
		)
		U1
		(
			.CLK(clk),
			.RST(rst),
			.CE(1'b1),

			.A({1'b0, a_q[47:24]}),
			.B({1'b0, b_q[16*i+15:16*i]}),
			.P(p[3*i + 1])
		);

		MULT_MACRO
		#(
			.LATENCY(3),
			.WIDTH_A(25),
			.WIDTH_B(17)
		)
		U2
		(
			.CLK(clk),
			.RST(rst),
			.CE(1'b1),

			.A({9'b0, a_q[63:48]}),
			.B({1'b0, b_q[16*i+15:16*i]}),
			.P(p[3*i + 2])
		);
	end

	reg_slice #(3, 7) U3
	(
		.clk(clk),
		.rst(rst),
		.data_in({b[63], a[63], is_signed}),
		.data_out({b_sign, a_sign, is_signed_q})
	);

	if(C_LATENCY > 8) begin
		reg_slice #(64, C_LATENCY - 8) U4
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
