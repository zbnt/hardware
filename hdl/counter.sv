
module counter #(parameter width = 32)
(
	input logic clk,
	input logic rst,
	output logic [width-1:0] count
);
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			count <= '0;
		end else begin
			count <= count + 'd1;
		end
	end
endmodule
