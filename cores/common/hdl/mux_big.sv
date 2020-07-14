
module mux_big
#(
	parameter C_WIDTH = 32,
	parameter C_INPUTS = 4,
	parameter C_DIVIDER = 2
)
(
	input logic clk,
	input logic rst_n,
	input logic enable,

	input logic [$clog2(C_INPUTS)-1:0] selector,
	input logic [C_WIDTH-1:0] values_in[0:C_INPUTS-1],
	output logic [C_WIDTH-1:0] value_out
);
	mux_big_impl
	#(
		.C_WIDTH(C_WIDTH),
		.C_INPUTS(C_INPUTS),
		.C_DIVIDER(C_DIVIDER)
	)
	U0
	(
		.clk(clk),
		.rst_n(rst_n),
		.enable(enable),

		.selector(selector),
		.values_in(values_in),
		.value_out(value_out)
	);
endmodule

module mux_big_impl
#(
	parameter C_WIDTH = 32,
	parameter C_INPUTS = 4,
	parameter C_DIVIDER = 2
)
(
	input logic clk,
	input logic rst_n,
	input logic enable,

	input logic [$clog2(C_INPUTS)-1:0] selector,
	input logic [C_WIDTH-1:0] values_in[0:C_INPUTS-1],
	output logic [C_WIDTH-1:0] value_out
);
	if(C_INPUTS <= C_DIVIDER) begin
		always_ff @(posedge clk) begin
			if(~rst_n) begin
				value_out <= '0;
			end else if(enable) begin
				value_out <= values_in[selector];
			end
		end
	end else begin
		logic [C_WIDTH-1:0] out_values[0:C_DIVIDER-1];

		for(genvar i = 0; i < C_DIVIDER; i++) begin
			logic [C_WIDTH-1:0] new_values[0:C_INPUTS/C_DIVIDER-1];

			for(genvar j = 0; j < C_INPUTS/C_DIVIDER; j++) begin
				always_comb begin
					new_values[j] = values_in[i*C_DIVIDER + j];
				end
			end

			mux_big_impl
			#(
				.C_WIDTH(C_WIDTH),
				.C_INPUTS(C_INPUTS/C_DIVIDER),
				.C_DIVIDER((C_INPUTS/C_DIVIDER) < C_DIVIDER ? (C_INPUTS/C_DIVIDER) : C_DIVIDER)
			)
			U0
			(
				.clk(clk),
				.rst_n(rst_n),
				.enable(enable),

				.selector(selector[$clog2(C_INPUTS/C_DIVIDER)-1:0]),
				.values_in(new_values),
				.value_out(out_values[i])
			);
		end

		always_ff @(posedge clk) begin
			if(~rst_n) begin
				value_out <= '0;
			end else if(enable) begin
				value_out <= out_values[selector[$clog2(C_INPUTS)-1:$clog2(C_INPUTS/C_DIVIDER)]];
			end
		end
	end
endmodule
