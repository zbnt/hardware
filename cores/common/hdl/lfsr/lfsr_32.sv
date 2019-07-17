
// https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf

module lfsr_32 #(parameter init_state = 32'd0)
(
	input logic clk,
	input logic rst,
	input logic enable,
	output logic [31:0] value
);
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			value <= init_state;
		end else if(enable) begin
			value <= {value[30:0], value[31] ^~ value[21] ^~ value[1] ^~ value[0]};
		end
	end
endmodule
