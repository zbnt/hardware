
// https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf

module lfsr_64 #(parameter init_state = 64'd0)
(
	input logic clk,
	input logic rst,
	input logic enable,
	output logic [63:0] value
);
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			value <= init_state;
		end else if(enable) begin
			value <= {value[62:0], value[63] ^~ value[62] ^~ value[60] ^~ value[59]};
		end
	end
endmodule
