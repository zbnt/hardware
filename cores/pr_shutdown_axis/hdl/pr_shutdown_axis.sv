/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module pr_shutdown_axis
#(
	parameter C_AXIS_TDATA_WIDTH = 32,
	parameter C_AXIS_TUSER_WIDTH = 1,
	parameter C_AXIS_TDEST_WIDTH = 1,
	parameter C_AXIS_TID_WIDTH = 1,

	parameter C_AXIS_HAS_TREADY = 1,
	parameter C_AXIS_HAS_TSTRB = 0,
	parameter C_AXIS_HAS_TKEEP = 0,
	parameter C_AXIS_HAS_TLAST = 1,
	parameter C_AXIS_HAS_TID = 0,
	parameter C_AXIS_HAS_TDEST = 0,
	parameter C_AXIS_HAS_TUSER = 0
)
(
	input logic clk,
	input logic rst_n,

	input logic shutdown_req,
	output logic shutdown_ack,

	// S_AXIS

	input logic [C_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
	input logic [(C_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb,
	input logic [(C_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tkeep,
	input logic [C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
	input logic [C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
	input logic [C_AXIS_TID_WIDTH-1:0] s_axis_tid,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	// M_AXIS

	output logic [C_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
	output logic [(C_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tstrb,
	output logic [(C_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tkeep,
	output logic [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
	output logic [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest,
	output logic [C_AXIS_TID_WIDTH-1:0] m_axis_tid,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic shutdown, in_transmission;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			shutdown <= 1'b0;
			shutdown_ack <= 1'b0;
			in_transmission <= 1'b0;
		end else begin
			shutdown_ack <= shutdown;

			if(C_AXIS_HAS_TLAST) begin
				if(s_axis_tvalid & s_axis_tready) begin
					in_transmission <= ~s_axis_tlast;
				end
			end else begin
				in_transmission <= 1'b0;
			end

			if(C_AXIS_HAS_TLAST) begin
				if(~in_transmission | (s_axis_tvalid & s_axis_tready & s_axis_tlast)) begin
					shutdown <= shutdown_req;
				end
			end else begin
				if(~s_axis_tvalid | ~s_axis_tready) begin
					shutdown <= shutdown_req;
				end
			end
		end
	end

	always_comb begin
		if(~shutdown) begin
			m_axis_tdata = s_axis_tdata;
			m_axis_tstrb = s_axis_tstrb;
			m_axis_tkeep = s_axis_tkeep;
			m_axis_tuser = s_axis_tuser;
			m_axis_tdest = s_axis_tdest;
			m_axis_tid = s_axis_tid;
			m_axis_tlast = s_axis_tlast;
			m_axis_tvalid = s_axis_tvalid;
			s_axis_tready = m_axis_tready;
		end else begin
			m_axis_tdata = '0;
			m_axis_tstrb = '0;
			m_axis_tkeep = '0;
			m_axis_tuser = '0;
			m_axis_tdest = '0;
			m_axis_tid = '0;
			m_axis_tlast = '0;
			m_axis_tvalid = '0;
			s_axis_tready = '0;
		end
	end
endmodule
