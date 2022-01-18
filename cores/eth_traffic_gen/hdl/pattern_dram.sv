/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pattern_dram
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_PATTERN_WIDTH = 2,
	parameter C_PATTERN_LENGTH = 2048
)
(
	input logic clk,

	input logic [$clog2(C_PATTERN_LENGTH/(C_AXI_WIDTH/8))-1:0] a,
	input logic [C_AXI_WIDTH-1:0] d,
	output logic [C_AXI_WIDTH-1:0] spo,
	input logic [(C_AXI_WIDTH/8)-1:0] we,
	output logic wdone,

	input logic [$clog2(C_PATTERN_LENGTH/(C_AXI_WIDTH/8))-1:0] dpra,
	output logic [C_PATTERN_WIDTH*(C_AXI_WIDTH/8)-1:0] dpo
);
	localparam C_MEM_SIZE = C_PATTERN_LENGTH * C_PATTERN_WIDTH;
	localparam C_MEM_WIDTH = C_PATTERN_WIDTH * (C_AXI_WIDTH / 8);

	logic mem_we;
	logic [C_MEM_WIDTH-1:0] mem_d, mem_spo;

	xpm_memory_dpdistram
	#(
		.ADDR_WIDTH_A($clog2(C_PATTERN_LENGTH / (C_AXI_WIDTH/8))),
		.ADDR_WIDTH_B($clog2(C_PATTERN_LENGTH / (C_AXI_WIDTH/8))),
		.BYTE_WRITE_WIDTH_A(C_MEM_WIDTH),
		.CLOCKING_MODE("common_clock"),
		.MEMORY_INIT_FILE("none"),
		.MEMORY_INIT_PARAM("0"),
		.MEMORY_OPTIMIZATION("true"),
		.MEMORY_SIZE(C_MEM_SIZE),
		.MESSAGE_CONTROL(0),
		.READ_DATA_WIDTH_A(C_MEM_WIDTH),
		.READ_DATA_WIDTH_B(C_MEM_WIDTH),
		.READ_LATENCY_A(1),
		.READ_LATENCY_B(0),
		.READ_RESET_VALUE_A("0"),
		.READ_RESET_VALUE_B("0"),
		.RST_MODE_A("SYNC"),
		.RST_MODE_B("SYNC"),
		.USE_EMBEDDED_CONSTRAINT(0),
		.USE_MEM_INIT(0),
		.WRITE_DATA_WIDTH_A(C_MEM_WIDTH)
	)
	U0
	(
		.clka(clk),
		.clkb(clk),

		.rsta(1'b0),
		.rstb(1'b0),

		.addra(a),
		.dina(mem_d),
		.douta(mem_spo),
		.wea(mem_we),

		.addrb(dpra),
		.doutb(dpo),

		.ena(1'b1),
		.enb(1'b1),

		.regcea(1'b1),
		.regceb(1'b1)
	);

	always_ff @(posedge clk) begin
		mem_we <= ~wdone & ~mem_we & |we;
		wdone <= mem_we;
	end

	for(genvar i = 0; i < C_AXI_WIDTH/8; ++i) begin
		for(genvar j = 0; j < 8; ++j) begin
			if(j < C_PATTERN_WIDTH) begin
				assign spo[8*i + j] = mem_spo[C_PATTERN_WIDTH*i + j];
				assign mem_d[C_PATTERN_WIDTH*i + j] = we[i] ? d[8*i + j] : mem_spo[C_PATTERN_WIDTH*i + j];
			end else begin
				assign spo[8*i + j] = 1'b0;
			end
		end
	end
endmodule
