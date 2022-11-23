module sync_ffs #(parameter C_WIDTH = 8, parameter C_STAGES = 2)
(
	input logic clk_src,
	input logic clk_dst,
	input logic [C_WIDTH-1:0] data_in,
	output logic [C_WIDTH-1:0] data_out
);
	(* ASYNC_REG = "TRUE" *) logic [C_WIDTH-1:0] sync_stages[0:C_STAGES-1];
	(* DONT_TOUCH = "TRUE" *) logic [C_WIDTH-1:0] sync_stages_in;

	// source clock domain

	always_ff @(posedge clk_src) begin
		sync_stages_in <= data_in;
	end

	// destination clock domain

	always_ff @(posedge clk_dst) begin
		sync_stages[0] <= sync_stages_in;
	end

	for (genvar i = 1; i < C_STAGES; ++i) begin
		always_ff @(posedge clk_dst) begin
			sync_stages[i] <= sync_stages[i-1];
		end
	end

	always_comb begin
		data_out = sync_stages[C_STAGES-1];
	end
endmodule

