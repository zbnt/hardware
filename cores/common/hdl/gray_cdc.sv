module gray_cdc #(parameter C_WIDTH = 8, parameter C_STAGES = 4)
(
	input logic clk_src,
	input logic clk_dst,
	input logic [C_WIDTH-1:0] data_in,
	output logic [C_WIDTH-1:0] data_out
);
	(* ASYNC_REG = "TRUE" *) logic [C_WIDTH-1:0] gray_sync_stages[0:C_STAGES-1];
	(* DONT_TOUCH = "TRUE" *) logic [C_WIDTH-1:0] gray_sync_in;

	// source clock domain

	always_ff @(posedge clk_src) begin
		gray_sync_in <= data_in ^ {1'b0, data_in[C_WIDTH-1:1]};
	end

	// destination clock domain

	always_ff @(posedge clk_dst) begin
		gray_sync_stages[0] <= gray_sync_in;
	end

	for (genvar i = 1; i < C_STAGES; ++i) begin
		always_ff @(posedge clk_dst) begin
			gray_sync_stages[i] <= gray_sync_stages[i-1];
		end
	end

	// decode gray code

	logic [C_WIDTH-1:0] gray_decoded;

	always_comb begin
		gray_decoded[C_WIDTH-1] = gray_sync_stages[C_STAGES-1][C_WIDTH-1];

		for (int i = C_WIDTH - 2; i >= 0; --i) begin
			gray_decoded[i] = gray_decoded[i+1] ^ gray_sync_stages[C_STAGES-1][i];
		end
	end

	always_ff @(posedge clk_dst) begin
		data_out <= gray_decoded;
	end
endmodule
