/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_startup
#(
	parameter C_FAMILY_TYPE = 0,
	parameter C_PROG_USR = "FALSE",
	parameter C_SIM_CCLK_FREQ = 0.0
)
(
	input wire clk,

	input wire gsr,
	input wire gts,
	input wire keyclearb,
	input wire pack,

	input wire fcsbo,
	input wire fcsbts,

	input wire usrcclko,
	input wire usrcclkts,

	input wire usrdoneo,
	input wire usrdonets,

	output wire cfgclk,
	output wire cfgmclk,
	output wire eos,
	output wire preq,

	input wire [3:0] do,
	input wire [3:0] dts,
	output wire [3:0] di
);
	if(~C_FAMILY_TYPE) begin
		STARTUPE2
		#(
			.PROG_USR(C_PROG_USR),
			.SIM_CCLK_FREQ(C_SIM_CCLK_FREQ)
		)
		U0
		(
			.CLK(clk),

			.GSR(gsr),
			.GTS(gts),
			.KEYCLEARB(keyclearb),
			.PACK(pack),

			.USRCCLKO(usrcclko),
			.USRCCLKTS(usrcclkts),

			.USRDONEO(usrdoneo),
			.USRDONETS(usrdonets),

			.CFGCLK(cfgclk),
			.CFGMCLK(cfgmclk),
			.EOS(eos),
			.PREQ(preq)
		);
	end else begin
		STARTUPE3
		#(
			.PROG_USR(C_PROG_USR),
			.SIM_CCLK_FREQ(C_SIM_CCLK_FREQ)
		)
		U0
		(
			.CLK(clk),

			.GSR(gsr),
			.GTS(gts),
			.KEYCLEARB(keyclearb),
			.PACK(pack),

			.FCSBO(fcsbo),
			.FCSBTS(fcsbts),

			.USRCCLKO(usrcclko),
			.USRCCLKTS(usrcclkts),

			.USRDONEO(usrdoneo),
			.USRDONETS(usrdonets),

			.CFGCLK(cfgclk),
			.CFGMCLK(cfgmclk),
			.EOS(eos),
			.PREQ(preq),

			.DO(do),
			.DTS(dts),
			.DI(di)
		);
	end
endmodule
