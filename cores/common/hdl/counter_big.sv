
module counter_big #(parameter width = 32)
(
	input logic clk,
	input logic rst,

	input logic enable,

	output logic [width-1:0] count
);
	always_ff @(posedge clk) begin
		if(rst) begin
			count[0] <= 1'b0;
		end else if(enable) begin
			count[0] <= ~count[0];
		end
	end

	for(genvar i = 1; i < width; ++i) begin
		always_ff @(posedge clk) begin
			if(rst) begin
				count[i] <= 1'b0;
			end else if(enable & count[i-1]) begin
				count[i] <= ~count[i];
			end
		end
	end
endmodule
