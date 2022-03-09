// https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf

module lfsr_prng
#(
	parameter width = 64,
	parameter xnor_count = 4,
	parameter xnor_0 = 63,
	parameter xnor_1 = 62,
	parameter xnor_2 = 60,
	parameter xnor_3 = 59,
	parameter xnor_4 = 0,
	parameter xnor_5 = 0
)
(
	input logic clk,
	input logic rst,
	input logic enable,
	input logic [width-1:0] value_in,
	output logic [width-1:0] value_out
);
	always_ff @(posedge clk) begin
		if(rst) begin
			value_out <= value_in;
		end else if(enable) begin
			case(xnor_count)
				3'd2: value_out <= {value_out[width-2:0], value_out[xnor_0] ^~ value_out[xnor_1]};
				3'd3: value_out <= {value_out[width-2:0], value_out[xnor_0] ^~ value_out[xnor_1] ^~ value_out[xnor_2]};
				3'd4: value_out <= {value_out[width-2:0], value_out[xnor_0] ^~ value_out[xnor_1] ^~ value_out[xnor_2] ^~ value_out[xnor_3]};
				3'd5: value_out <= {value_out[width-2:0], value_out[xnor_0] ^~ value_out[xnor_1] ^~ value_out[xnor_2] ^~ value_out[xnor_3] ^~ value_out[xnor_4]};
				3'd6: value_out <= {value_out[width-2:0], value_out[xnor_0] ^~ value_out[xnor_1] ^~ value_out[xnor_2] ^~ value_out[xnor_3] ^~ value_out[xnor_4] ^~ value_out[xnor_5]};
			endcase
		end
	end
endmodule
