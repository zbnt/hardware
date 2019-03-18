`timescale 1ns / 1ps

module register_bank #(parameter num_regs = 2, parameter addr_width = 7, parameter allow_write = {num_regs{1'b1}}, parameter reg_width = 32)
(
	input logic clk,
	input logic write_enable,
	input logic [addr_width-1:0] write_index,
	input logic [reg_width-1:0] write_value,
	input logic [reg_width-1:0] reg_in[0:num_regs-1],
	output logic [reg_width-1:0] reg_val[0:num_regs-1]
);
	integer i;

	always_ff @(posedge clk) begin
		for(i = 0; i < num_regs; i = i+1) begin
			if(allow_write[i]) begin
				if(write_enable && write_index == i) begin
					reg_val[i] <= write_value;
				end else begin
					reg_val[i] <= reg_in[i];
				end
			end
		end
	end

	always_comb begin
		for(i = 0; i < num_regs; i = i+1) begin
			if(~allow_write[i]) begin
				reg_val[i] = reg_in[i];
			end
		end
	end
endmodule
