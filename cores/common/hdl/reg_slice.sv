
module reg_slice
#(
	parameter C_WIDTH = 32,
	parameter C_NUM_STAGES = 2,
	parameter C_USE_ENABLE = 0
)
(
	input logic clk,
	input logic rst,
	input logic enable,

	input logic [C_WIDTH-1:0] data_in,
	output logic [C_WIDTH-1:0] data_out
);
	logic [C_WIDTH-1:0] stages[0:C_NUM_STAGES-1];

	always_ff @(posedge clk) begin
		if(rst) begin
			stages[0] <= '0;
		end else if(C_USE_ENABLE == 0 || enable) begin
			stages[0] <= data_in;
		end
	end

	for(genvar i = 1; i < C_NUM_STAGES; ++i) begin
		always_ff @(posedge clk) begin
			if(rst) begin
				stages[i] <= '0;
			end else if(C_USE_ENABLE == 0 || enable) begin
				stages[i] <= stages[i-1];
			end
		end
	end

	always_comb begin
		data_out = stages[C_NUM_STAGES-1];
	end
endmodule

