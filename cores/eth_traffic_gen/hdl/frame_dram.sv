/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module frame_dram #(parameter axi_width = 32)
(
	input logic clk,

	input logic [10:0] a,
	input logic [axi_width-1:0] d,
	output logic [axi_width-1:0] spo,
	input logic [(axi_width/8)-1:0] we,

	input logic [10:0] dpra,
	output logic [7:0] dpo
);
	logic [axi_width-1:0] dpo_full;
	logic [7:0] dpo_bytes[0:(axi_width/8)-1];

	xpm_memory_dpdistram
	#(
		.ADDR_WIDTH_A(11 - $clog2(axi_width/8)),
		.ADDR_WIDTH_B(11 - $clog2(axi_width/8)),
		.BYTE_WRITE_WIDTH_A(8),
		.CLOCKING_MODE("common_clock"),
		.MEMORY_INIT_FILE("none"),
		.MEMORY_INIT_PARAM("0"),
		.MEMORY_OPTIMIZATION("true"),
		.MEMORY_SIZE(16384),
		.MESSAGE_CONTROL(0),
		.READ_DATA_WIDTH_A(axi_width),
		.READ_DATA_WIDTH_B(axi_width),
		.READ_LATENCY_A(0),
		.READ_LATENCY_B(0),
		.READ_RESET_VALUE_A("0"),
		.READ_RESET_VALUE_B("0"),
		.RST_MODE_A("SYNC"),
		.RST_MODE_B("SYNC"),
		.USE_EMBEDDED_CONSTRAINT(0),
		.USE_MEM_INIT(0),
		.WRITE_DATA_WIDTH_A(axi_width)
	)
	U0
	(
		.clka(clk),
		.clkb(clk),

		.rsta(1'b0),
		.rstb(1'b0),

		.addra(a[10:$clog2(axi_width/8)]),
		.dina(d),
		.douta(spo),
		.wea(we),

		.addrb(dpra[10:$clog2(axi_width/8)]),
		.doutb(dpo_full),

		.ena(1'b1),
		.enb(1'b1),

		.regcea(1'b1),
		.regceb(1'b1)
	);

	for(genvar i = 0; i < axi_width/8; ++i) begin
		always_comb begin
			dpo_bytes[i] = dpo_full[i*8+7:i*8];
		end
	end

	always_comb begin
		dpo = dpo_bytes[dpra[$clog2(axi_width/8)-1:0]];
	end
endmodule
