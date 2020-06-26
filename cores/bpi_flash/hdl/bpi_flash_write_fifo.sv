/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module bpi_flash_write_fifo
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_MEM_WIDTH = 16,
	parameter C_FIFO_DEPTH = 128
)
(
	input logic clk,
	input logic rst_n,

	input logic enable,

	// S_AXI

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wlast,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	// M_AXIS

	output logic [C_MEM_WIDTH-1:0] m_axis_tdata,
	output logic [$clog2(C_AXI_WIDTH/C_MEM_WIDTH)+1:0] m_axis_tuser, // {offset, strb_valid, axi_word_end}
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	logic [C_MEM_WIDTH-1:0] s_fifo_tdata;
	logic [$clog2(C_AXI_WIDTH/C_MEM_WIDTH)+1:0] s_fifo_tuser;
	logic s_fifo_tlast, s_fifo_tvalid, s_fifo_tready;

	if(C_AXI_WIDTH != C_MEM_WIDTH) begin
		// We need to downsize the interface before pushing data into the fifo
		// An axi-word (C_AXI_WIDTH) needs to be split into multiple mem-words (C_MEM_WIDTH)

		logic [$clog2(C_AXI_WIDTH/C_MEM_WIDTH)-1:0] count;

		logic [C_AXI_WIDTH-1:0] data_sr;
		logic [(C_AXI_WIDTH/8)-1:0] strb_sr;
		logic data_last, data_valid;

		logic axi_word_end, strb_valid;

		always_ff @(posedge clk) begin
			if(~rst_n) begin
				count <= '0;

				data_sr <= '0;
				strb_sr <= '0;
				data_last <= 1'b0;
				data_valid <= 1'b0;

				s_axi_wready <= 1'b0;

				s_fifo_tdata <= '0;
				s_fifo_tuser <= 1'b0;
				s_fifo_tlast <= 1'b0;
				s_fifo_tvalid <= 1'b0;
			end else begin
				s_axi_wready <= enable & ~data_valid;

				if(s_axi_wvalid & s_axi_wready) begin
					count <= '0;

					data_valid <= 1'b1;
					data_sr <= s_axi_wdata;
					strb_sr <= s_axi_wstrb;
					data_last <= s_axi_wlast;

					s_axi_wready <= 1'b0;
				end

				if(data_valid & (~s_fifo_tvalid | s_fifo_tready)) begin
					count <= count + 'd1;

					data_sr <= {'0, data_sr[C_AXI_WIDTH-1:C_MEM_WIDTH]};
					strb_sr <= {'0, strb_sr[(C_AXI_WIDTH/8)-1:(C_MEM_WIDTH/8)]};

					s_fifo_tdata <= data_sr[C_MEM_WIDTH-1:0];
					s_fifo_tuser <= {count, strb_valid, axi_word_end};
					s_fifo_tlast <= axi_word_end & data_last;

					// We can discard mem-words with invalid strobes, but we can't discard the entire axi-word or data
					// will be written to the wrong address, so the first mem-word in an axi-word will always be written.
					s_fifo_tvalid <= strb_valid | ~(&count);

					if(~(|strb_sr[(C_AXI_WIDTH/8)-1:(C_MEM_WIDTH/8)])) begin
						data_valid <= 1'b0;
					end
				end

				if(~data_valid & s_fifo_tvalid & s_fifo_tready) begin
					s_fifo_tvalid <= 1'b0;
				end
			end
		end

		always_comb begin
			axi_word_end = ~(|strb_sr[(C_AXI_WIDTH/8)-1:(C_MEM_WIDTH/8)]); // strb_sr will be all zeros the next time it is shifted
			strb_valid = &strb_sr[(C_MEM_WIDTH/8)-1:0];                    // partial/unaligned mem-word writes not allowed
		end
	end else begin
		// No downsize needed, feed the data directly to the fifo

		always_comb begin
			s_fifo_tdata = s_axi_wready;
			s_fifo_tuser = {&s_axi_wstrb, 1'b1};
			s_fifo_tlast = s_axi_wlast;
			s_fifo_tvalid = enable & s_fifo_tvalid;

			s_axi_wready = enable & s_fifo_tready;
		end
	end

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_FIFO_DEPTH),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_MEM_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH($clog2(C_AXI_WIDTH/C_MEM_WIDTH) + 2),
		.USE_ADV_FEATURES("1000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U1
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_fifo_tdata),
		.s_axis_tlast(s_fifo_tlast),
		.s_axis_tuser(s_fifo_tuser),
		.s_axis_tvalid(s_fifo_tvalid),
		.s_axis_tready(s_fifo_tready),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);
endmodule
