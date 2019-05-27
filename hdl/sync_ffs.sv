
module sync_ffs #(parameter width, parameter stages = 2)
(
	input logic clk,
	input logic [width-1:0] data_in,
	output logic [width-1:0] data_out
);
	logic [width-1:0] sync_stages[0:stages-1];
	genvar i;

	always_ff @(posedge clk) begin
		sync_stages[0] <= data_in;
	end

	for(i = 1; i < stages; ++i) begin
		always_ff @(posedge clk) begin
			sync_stages[i] <= sync_stages[i-1];
		end
	end

	always_comb begin
		data_out = sync_stages[stages-1];
	end
endmodule

