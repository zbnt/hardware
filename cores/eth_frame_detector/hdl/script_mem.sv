/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module script_mem #(parameter C_AXI_WIDTH = 32, parameter C_MAX_SCRIPT_SIZE = 2048)
(
	input logic clk_a,
	input logic clk_b,
	input logic rst_n,

	input logic [$clog2(4*C_MAX_SCRIPT_SIZE)-1:0] a,
	input logic [C_AXI_WIDTH-1:0] d,
	output logic [C_AXI_WIDTH-1:0] qspo,
	input logic we,
	input logic req,
	output logic ack,

	input logic [15:0] dpra,
	output logic [31:0] qdpo
);
	// CDC

	logic [$clog2(4*C_MAX_SCRIPT_SIZE)-1:0] a_cdc;
	logic [C_AXI_WIDTH-1:0] d_cdc, qspo_cdc;
	logic we_cdc, we_pulse_cdc, req_cdc, ack_cdc;

	always_ff @(posedge clk_b) begin
		if(req_cdc & ~ack_cdc) begin
			we_pulse_cdc <= we_cdc;
			ack_cdc <= 1'b1;
		end else begin
			we_pulse_cdc <= 1'b0;

			if(~req_cdc) begin
				ack_cdc <= 1'b0;
			end
		end
	end

	bus_cdc #(C_AXI_WIDTH + $clog2(4*C_MAX_SCRIPT_SIZE) + 2, 2) U0
	(
		.clk_src(clk_a),
		.clk_dst(clk_b),
		.data_in({d, a, we, req}),
		.data_out({d_cdc, a_cdc, we_cdc, req_cdc})
	);

	bus_cdc #(C_AXI_WIDTH + 1, 2) U1
	(
		.clk_src(clk_b),
		.clk_dst(clk_a),
		.data_in({qspo_cdc, ack_cdc}),
		.data_out({qspo, ack})
	);

	// Memory instance

	localparam C_NUM_ENTRIES = 32 * C_MAX_SCRIPT_SIZE / C_AXI_WIDTH;

	logic [C_AXI_WIDTH-1:0] qdpo_full;
	logic [31:0] qdpo_words[0:(C_AXI_WIDTH/32)-1];

	xpm_memory_tdpram
	#(
		.ADDR_WIDTH_A($clog2(C_NUM_ENTRIES)),
		.ADDR_WIDTH_B($clog2(C_NUM_ENTRIES)),
		.BYTE_WRITE_WIDTH_A(C_AXI_WIDTH),
		.CLOCKING_MODE("common_clock"),
		.MEMORY_INIT_FILE("none"),
		.MEMORY_INIT_PARAM("0"),
		.MEMORY_OPTIMIZATION("true"),
		.MEMORY_SIZE(32 * C_MAX_SCRIPT_SIZE),
		.MESSAGE_CONTROL(0),
		.READ_DATA_WIDTH_A(C_AXI_WIDTH),
		.READ_DATA_WIDTH_B(C_AXI_WIDTH),
		.READ_LATENCY_A(1),
		.READ_LATENCY_B(1),
		.READ_RESET_VALUE_A("0"),
		.READ_RESET_VALUE_B("0"),
		.RST_MODE_A("SYNC"),
		.RST_MODE_B("SYNC"),
		.USE_EMBEDDED_CONSTRAINT(0),
		.USE_MEM_INIT(0),
		.WRITE_DATA_WIDTH_A(C_AXI_WIDTH)
	)
	U2
	(
		.clka(clk_b),
		.clkb(clk_b),

		.rsta(~rst_n),
		.rstb(~rst_n),
		.sleep(1'b0),

		.addra(a_cdc[$clog2(4*C_MAX_SCRIPT_SIZE)-1:$clog2(C_AXI_WIDTH/8)]),
		.dina(d_cdc),
		.douta(qspo_cdc),
		.wea(we_pulse_cdc),

		.addrb(dpra[$clog2(C_MAX_SCRIPT_SIZE)-1:$clog2(C_AXI_WIDTH/32)]),
		.doutb(qdpo_full),
		.web(1'b0),

		.ena(1'b1),
		.enb(1'b1),

		.regcea(1'b1),
		.regceb(1'b1),

		.injectdbiterra(1'b0),
		.injectdbiterrb(1'b0),

		.injectsbiterra(1'b0),
		.injectsbiterrb(1'b0)
	);

	for(genvar i = 0; i < C_AXI_WIDTH/32; ++i) begin
		always_comb begin
			qdpo_words[i] = qdpo_full[i*32+31:i*32];
		end
	end

	always_comb begin
		if(C_AXI_WIDTH == 32) begin
			qdpo = qdpo_full;
		end else begin
			qdpo = qdpo_words[dpra[$clog2(C_AXI_WIDTH/32)-1:0]];
		end
	end
endmodule
