/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	axi_mm_fifo: AXI-MM Virtual FIFO

	Implements a FIFO using external memory accessed via AXI
*/

module axi_mm_fifo
#(
	parameter C_WIDTH = 64,
	parameter C_START_ADDR = 0,
	parameter C_END_ADDR = 134217727,
	parameter C_MAX_OCCUPANCY = ((C_END_ADDR - C_START_ADDR + 1) / (C_WIDTH * C_WIDTH / 8)) * (C_WIDTH - 2)
)
(
	input logic clk_axis,
	input logic rst_axis_n,

	input logic clk_axi,
	input logic rst_axi_n,

	input logic flush,
	output logic [$clog2(C_MAX_OCCUPANCY+1)-1:0] occupancy,

	// M_AXI

	output logic [$clog2(C_END_ADDR+1)-1:0] m_axi_araddr,
	output logic [7:0] m_axi_arlen,
	output logic m_axi_arvalid,
	input logic m_axi_arready,

	input logic [C_WIDTH-1:0] m_axi_rdata,
	input logic [1:0] m_axi_rresp,
	input logic m_axi_rlast,
	input logic m_axi_rvalid,
	output logic m_axi_rready,

	output logic [$clog2(C_END_ADDR+1)-1:0] m_axi_awaddr,
	output logic [7:0] m_axi_awlen,
	output logic m_axi_awvalid,
	input logic m_axi_awready,

	output logic [C_WIDTH-1:0] m_axi_wdata,
	output logic m_axi_wlast,
	output logic m_axi_wvalid,
	input logic m_axi_wready,

	input logic [1:0] m_axi_bresp,
	input logic m_axi_bvalid,
	output logic m_axi_bready,

	// M_AXIS

	output logic [C_WIDTH-1:0] m_axis_tdata,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready,

	// S_AXIS

	input logic [C_WIDTH-1:0] s_axis_tdata,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready
);
	enum logic [1:0] {ST_SETUP_WRITE, ST_WRITE_MEM, ST_SETUP_READ, ST_READ_MEM} state;

	logic [$clog2(C_MAX_OCCUPANCY+1)-1:0] axi_occupancy;
	logic flush_cdc;

	logic s2mm_enable, s2mm_busy;
	logic mm2s_enable, mm2s_busy;
	logic [$clog2(C_END_ADDR+1)-1:0] s2mm_ptr, mm2s_ptr;

	logic [C_WIDTH-1:0] axis_s2mm_tdata;
	logic [$clog2(C_WIDTH * 2 + 1)-1:0] axis_s2mm_occupancy;
	logic axis_s2mm_tlast, axis_s2mm_tvalid, axis_s2mm_tready;

	logic [C_WIDTH-1:0] axis_mm2s_tdata;
	logic [$clog2(C_WIDTH * 2 + 1)-1:0] axis_mm2s_occupancy;
	logic axis_mm2s_tlast, axis_mm2s_tvalid, axis_mm2s_tready;

	always_ff @(posedge clk_axi) begin
		if(~rst_axi_n) begin
			state <= ST_SETUP_WRITE;

			s2mm_enable <= 1'b0;
			mm2s_enable <= 1'b0;

			axi_occupancy <= '0;
		end else begin
			case(state)
				ST_SETUP_WRITE: begin
					if(axi_occupancy < C_MAX_OCCUPANCY && (flush_cdc || axis_s2mm_occupancy >= C_WIDTH - 2)) begin
						state <= ST_WRITE_MEM;
						s2mm_enable <= 1'b1;
					end else begin
						state <= ST_SETUP_READ;
					end
				end

				ST_WRITE_MEM: begin
					if(~s2mm_enable & ~s2mm_busy) begin
						state <= ST_SETUP_READ;
						axi_occupancy <= axi_occupancy + (C_WIDTH - 2);
					end

					s2mm_enable <= 1'b0;
				end

				ST_SETUP_READ: begin
					if(axi_occupancy != 'd0 && axis_mm2s_occupancy <= C_WIDTH) begin
						state <= ST_READ_MEM;
						mm2s_enable <= 1'b1;
					end else begin
						state <= ST_SETUP_WRITE;
					end
				end

				ST_READ_MEM: begin
					if(~mm2s_enable & ~mm2s_busy) begin
						state <= ST_SETUP_WRITE;
						axi_occupancy <= axi_occupancy - (C_WIDTH - 2);
					end

					mm2s_enable <= 1'b0;
				end
			endcase
		end
	end

	// S2MM

	axi_mm_fifo_s2mm
	#(
		C_WIDTH,
		C_START_ADDR,
		C_END_ADDR,
		$clog2(C_WIDTH * 2 + 1)
	)
	U0
	(
		.clk(clk_axi),
		.rst_n(rst_axi_n),

		.enable(s2mm_enable),
		.busy(s2mm_busy),

		.values_available(axis_s2mm_occupancy),
		.mem_ptr(s2mm_ptr),

		// M_AXI

		.m_axi_awaddr(m_axi_awaddr),
		.m_axi_awlen(m_axi_awlen),
		.m_axi_awvalid(m_axi_awvalid),
		.m_axi_awready(m_axi_awready),

		.m_axi_wdata(m_axi_wdata),
		.m_axi_wlast(m_axi_wlast),
		.m_axi_wvalid(m_axi_wvalid),
		.m_axi_wready(m_axi_wready),

		.m_axi_bresp(m_axi_bresp),
		.m_axi_bvalid(m_axi_bvalid),
		.m_axi_bready(m_axi_bready),

		// S_AXIS

		.s_axis_tdata(axis_s2mm_tdata),
		.s_axis_tlast(axis_s2mm_tlast),
		.s_axis_tvalid(axis_s2mm_tvalid),
		.s_axis_tready(axis_s2mm_tready)
	);

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(4),
		.CLOCKING_MODE("independent_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_WIDTH * 2),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH($clog2(C_WIDTH * 2 + 1)),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1400"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U1
	(
		.m_aclk(clk_axi),
		.s_aclk(clk_axis),
		.s_aresetn(rst_axis_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.rd_data_count_axis(axis_s2mm_occupancy),

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),
		.s_axis_tready(s_axis_tready),

		.m_axis_tdata(axis_s2mm_tdata),
		.m_axis_tlast(axis_s2mm_tlast),
		.m_axis_tvalid(axis_s2mm_tvalid),
		.m_axis_tready(axis_s2mm_tready),

		.s_axis_tuser(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

	// MM2S

	axi_mm_fifo_mm2s
	#(
		C_WIDTH,
		C_START_ADDR,
		C_END_ADDR
	)
	U2
	(
		.clk(clk_axi),
		.rst_n(rst_axi_n),

		.enable(mm2s_enable),
		.busy(mm2s_busy),

		.mem_ptr(mm2s_ptr),

		// M_AXI

		.m_axi_araddr(m_axi_araddr),
		.m_axi_arlen(m_axi_arlen),
		.m_axi_arvalid(m_axi_arvalid),
		.m_axi_arready(m_axi_arready),

		.m_axi_rdata(m_axi_rdata),
		.m_axi_rresp(m_axi_rresp),
		.m_axi_rlast(m_axi_rlast),
		.m_axi_rvalid(m_axi_rvalid),
		.m_axi_rready(m_axi_rready),

		// M_AXIS

		.m_axis_tdata(axis_mm2s_tdata),
		.m_axis_tlast(axis_mm2s_tlast),
		.m_axis_tvalid(axis_mm2s_tvalid),
		.m_axis_tready(axis_mm2s_tready)
	);

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(4),
		.CLOCKING_MODE("independent_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(C_WIDTH * 2),
		.FIFO_MEMORY_TYPE("block"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("1004"),
		.WR_DATA_COUNT_WIDTH($clog2(C_WIDTH * 2 + 1))
	)
	U3
	(
		.m_aclk(clk_axis),
		.s_aclk(clk_axi),
		.s_aresetn(rst_axi_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.wr_data_count_axis(axis_mm2s_occupancy),

		.s_axis_tdata(axis_mm2s_tdata),
		.s_axis_tlast(axis_mm2s_tlast),
		.s_axis_tvalid(axis_mm2s_tvalid),
		.s_axis_tready(axis_mm2s_tready),

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid),
		.m_axis_tready(m_axis_tready),

		.s_axis_tuser(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

	// CDC

	bus_cdc #($clog2(C_MAX_OCCUPANCY+1), 3) U4
	(
		.clk_src(clk_axi),
		.clk_dst(clk_axis),
		.data_in(axi_occupancy),
		.data_out(occupancy)
	);

	sync_ffs #(1, 3) U5
	(
		.clk_src(clk_axis),
		.clk_dst(clk_axi),
		.data_in(flush),
		.data_out(flush_cdc)
	);
endmodule
