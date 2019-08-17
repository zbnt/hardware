
module counter_big #(parameter width = 32)
(
	input logic clk,
	input logic rst,

	input logic enable,

	output logic [width-1:0] count
);
	counter_big_impl #(width) U0
	(
		.clk(clk),
		.rst(rst),

		.enable(1'b1),
		.carry_in(enable),
		.carry_out(),

		.count(count)
	);
endmodule

module counter_big_impl #(parameter width)
(
	input logic clk,
	input logic rst,

	input logic enable,
	input logic carry_in,
	output logic carry_out,

	output logic [width-1:0] count
);
	if(width <= 8) begin
		always_ff @(posedge clk or posedge rst) begin
			if(rst) begin
				count <= '0;
			end else if(enable) begin
				count <= count + {{(width-1){1'b0}}, carry_in};
			end
		end

		always_comb begin
			carry_out = (count == '1 && carry_in);
		end
	end else begin
		logic carry_out_prev;

		counter_big_impl #(8) U0
		(
			.clk(clk),
			.rst(rst),

			.enable(enable),
			.carry_in(carry_in),
			.carry_out(carry_out_prev),

			.count(count[7:0])
		);

		counter_big_impl #(width-8) U1
		(
			.clk(clk),
			.rst(rst),

			.enable(count[7]),
			.carry_in(carry_out_prev),
			.carry_out(carry_out),

			.count(count[width-1:8])
		);
	end
endmodule
