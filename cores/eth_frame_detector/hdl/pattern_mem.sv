/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pattern_mem
(
	input logic clk,

	input logic [10:0] a,
	input logic [7:0] d,
	output logic [7:0] qspo,
	input logic we,

	input logic [10:0] dpra,
	output logic [7:0] qdpo
);
	xpm_memory_dpdistram
	#(
		.ADDR_WIDTH_A(11),
		.ADDR_WIDTH_B(11),
		.BYTE_WRITE_WIDTH_A(30),
		.CLOCKING_MODE("common_clock"),
		.MEMORY_INIT_FILE("none"),
		.MEMORY_INIT_PARAM("0"),
		.MEMORY_OPTIMIZATION("true"),
		.MEMORY_SIZE(46080),
		.MESSAGE_CONTROL(0),
		.READ_DATA_WIDTH_A(30),
		.READ_DATA_WIDTH_B(30),
		.READ_LATENCY_A(1),
		.READ_LATENCY_B(1),
		.READ_RESET_VALUE_A("0"),
		.READ_RESET_VALUE_B("0"),
		.RST_MODE_A("SYNC"),
		.RST_MODE_B("SYNC"),
		.USE_EMBEDDED_CONSTRAINT(0),
		.USE_MEM_INIT(0),
		.WRITE_DATA_WIDTH_A(30)
	)
	U0
	(
		.clka(clk),
		.clkb(clk),

		.rsta(1'b0),
		.rstb(1'b0),

		.addra(a),
		.dina(d),
		.douta(qspo),
		.wea(we),

		.addrb(dpra),
		.doutb(qdpo),

		.ena(1'b1),
		.enb(1'b1),

		.regcea(1'b1),
		.regceb(1'b1)
	);
endmodule
