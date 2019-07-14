/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module frame_dram
(
	input logic clk,

	input logic [10:0] a,
	input logic [7:0] d,
	output logic [7:0] spo,
	input logic we,

	input logic [10:0] dpra,
	output logic [7:0] dpo
);
	xpm_memory_dpdistram
	#(
		.ADDR_WIDTH_A(11),
		.ADDR_WIDTH_B(11),
		.BYTE_WRITE_WIDTH_A(8),
		.CLOCKING_MODE("common_clock"),
		.MEMORY_INIT_FILE("none"),
		.MEMORY_INIT_PARAM("0"),
		.MEMORY_OPTIMIZATION("true"),
		.MEMORY_SIZE(16384),
		.MESSAGE_CONTROL(0),
		.READ_DATA_WIDTH_A(8),
		.READ_DATA_WIDTH_B(8),
		.READ_LATENCY_A(0),
		.READ_LATENCY_B(0),
		.READ_RESET_VALUE_A("0"),
		.READ_RESET_VALUE_B("0"),
		.RST_MODE_A("SYNC"),
		.RST_MODE_B("SYNC"),
		.USE_EMBEDDED_CONSTRAINT(0),
		.USE_MEM_INIT(0),
		.WRITE_DATA_WIDTH_A(8)
	)
	U0
	(
		.clka(clk),
		.clkb(clk),

		.rsta(1'b0),
		.rstb(1'b0),

		.addra(a),
		.dina(d),
		.douta(spo),
		.wea(we),

		.addrb(dpra),
		.doutb(dpo),

		.ena(1'b1),
		.enb(1'b1),

		.regcea(1'b1),
		.regceb(1'b1)
	);
endmodule
