module bus_cdc #(parameter C_WIDTH = 8, parameter C_STAGES = 2, parameter C_EXT_TRIGGER = 0)
(
	input logic clk_src,
	input logic clk_dst,
	input logic trigger,
	input logic [C_WIDTH-1:0] data_in,
	output logic [C_WIDTH-1:0] data_out
);
	logic in_trigger, in_done;
	logic [C_WIDTH-1:0] in_reg;

	logic out_done;
	logic [C_WIDTH-1:0] out_sync;

	xpm_cdc_handshake
	#(
		.DEST_EXT_HSK(0),
		.DEST_SYNC_FF(C_STAGES),
		.SRC_SYNC_FF(C_STAGES),
		.WIDTH(C_WIDTH)
	)
	U0
	(
		.src_clk(clk_src),
		.src_in(in_reg),
		.src_send(in_trigger),
		.src_rcv(in_done),

		.dest_clk(clk_dst),
		.dest_out(out_sync),
		.dest_req(out_done),
		.dest_ack(1'b0)
	);

	always_ff @(posedge clk_src) begin
		case ({in_done, in_trigger})
			2'b00: begin
				if (C_EXT_TRIGGER == '0 || trigger) begin
					in_trigger <= 1'b1;
					in_reg <= data_in;
				end
			end

			2'b11: begin
				in_trigger <= 1'b0;
			end
		endcase
	end

	always_ff @(posedge clk_dst) begin
		if (out_done) begin
			data_out <= out_sync;
		end
	end
endmodule
