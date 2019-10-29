
module bus_cdc #(parameter width, parameter stages = 2, parameter ext_trigger = 0)
(
	input logic clk_src,
	input logic clk_dst,
	input logic trigger,
	input logic [width-1:0] data_in,
	output logic [width-1:0] data_out
);
	// source clock domain

	(* DONT_TOUCH = "TRUE" *) logic [width-1:0] bus_sync_in;
	logic bus_sync_ack;

	always_ff @(posedge clk_src) begin
		if(~bus_sync_ack && (trigger || ~ext_trigger)) begin
			bus_sync_in <= data_in;
		end
	end

	// destination clock domain

	logic [width-1:0] bus_sync_out;
	logic bus_sync_ready;

	always_ff @(posedge clk_dst) begin
		if(bus_sync_ready) begin
			bus_sync_out <= bus_sync_in;
		end
	end

	always_comb begin
		data_out = bus_sync_out;
	end

	// synchronizer for handshake signals

	sync_ffs #(1, stages) U0
	(
		.clk_src(clk_src),
		.clk_dst(clk_dst),
		.data_in(~bus_sync_ack && (trigger || ~ext_trigger)),
		.data_out(bus_sync_ready)
	);

	sync_ffs #(1, stages) U1
	(
		.clk_src(clk_dst),
		.clk_dst(clk_src),
		.data_in(bus_sync_ready),
		.data_out(bus_sync_ack)
	);
endmodule
