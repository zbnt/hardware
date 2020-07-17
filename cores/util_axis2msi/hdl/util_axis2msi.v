/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module util_axis2msi
(
	input wire clk,
	input wire rst_n,

	input wire [7:0] s_axis_tdata,
	input wire s_axis_tvalid,
	output reg s_axis_tready,

	output reg [4:0] msi_num,
	output reg msi_req,
	input wire msi_grant
);
	always @(posedge clk) begin
		if(~rst_n) begin
			msi_num <= 5'd0;
			msi_req <= 1'b0;
			s_axis_tready <= 1'b0;
		end else if(~msi_req) begin
			s_axis_tready <= 1'b1;

			if(s_axis_tready & s_axis_tvalid) begin
				msi_num <= s_axis_tdata[4:0];
				msi_req <= 1'b1;

				s_axis_tready <= 1'b0;
			end
		end else begin
			s_axis_tready <= 1'b0;

			if(msi_grant) begin
				msi_req <= 1'b0;
			end
		end
	end
endmodule
