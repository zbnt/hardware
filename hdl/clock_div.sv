`timescale 1ns / 1ps

module clock_div #(parameter out_freq = 60, parameter in_freq = 100000000, parameter width = 32)
(
	input logic inclk,
	input logic rst,
	output logic outclk
);
	logic clk_next;
	logic [width-1:0] count, count_next;

	always_ff @(posedge inclk) begin
		outclk <= clk_next;
		count <= count_next;
	end

	always_comb begin
		if(rst) begin
			clk_next = 0;
			count_next = '0;
		end else begin
			if(count == in_freq/(2*out_freq) - 1) begin
				clk_next = !outclk;
				count_next = '0;
			end else begin
				clk_next = outclk;
				count_next = count + 1;
			end
		end
	end
endmodule
