/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_irq2axis
#(
	parameter C_IRQ_NUMBER = 0
)
(
	input wire clk,
	input wire rst_n,

	input wire irq,

	output wire [7:0] m_axis_tdata,
	output reg m_axis_tvalid,
	input wire m_axis_tready
);
	reg irq_last;

	assign m_axis_tdata = C_IRQ_NUMBER;

	always @(posedge clk) begin
		if(~rst_n) begin
			irq_last <= 1'b0;
			m_axis_tvalid <= 1'b0;
		end else begin
			irq_last <= irq;

			if(~m_axis_tvalid | m_axis_tready) begin
				m_axis_tvalid <= irq & ~irq_last;
			end
		end
	end
endmodule
