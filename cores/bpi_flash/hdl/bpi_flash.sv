/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

/*!
	bpi_flash: BPI Flash

	Allows accessing a BPI Flash memory using an AXI4 interface
*/

module bpi_flash
#(
	parameter C_AXI_WIDTH = 32,
	parameter C_AXI_RD_FIFO_DEPTH = 128,
	parameter C_AXI_WR_FIFO_DEPTH = 128,

	parameter C_MEM_WIDTH = 16,
	parameter C_MEM_SIZE = 134217728,

	parameter C_ADDR_TO_CEL_TIME = 3,
	parameter C_OEL_TO_DQ_TIME = 6,
	parameter C_WEL_TO_DQ_TIME = 1,
	parameter C_DQ_TO_WEH_TIME = 6,
	parameter C_IO_TO_IO_TIME = 5
)
(
	input logic clk,
	input logic rst_n,

	// S_AXI

	input logic [$clog2(C_MEM_SIZE)-1:0] s_axi_awaddr,
	input logic [7:0] s_axi_awlen,
	input logic [2:0] s_axi_awsize,
	input logic [1:0] s_axi_awburst,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [C_AXI_WIDTH-1:0] s_axi_wdata,
	input logic [(C_AXI_WIDTH/8)-1:0] s_axi_wstrb,
	input logic s_axi_wlast,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready,

	input logic [$clog2(C_MEM_SIZE)-1:0] s_axi_araddr,
	input logic [7:0] s_axi_arlen,
	input logic [2:0] s_axi_arsize,
	input logic [1:0] s_axi_arburst,
	input logic s_axi_arvalid,
	output logic s_axi_arready,

	output logic [C_AXI_WIDTH-1:0] s_axi_rdata,
	output logic [1:0] s_axi_rresp,
	output logic s_axi_rvalid,
	output logic s_axi_rlast,
	input logic s_axi_rready,

	// BPI

	output logic [$clog2(8*C_MEM_SIZE/C_MEM_WIDTH)-1:0] bpi_a,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_o,
	output logic [C_MEM_WIDTH-1:0] bpi_dq_t,
	input logic [C_MEM_WIDTH-1:0] bpi_dq_i,

	output logic bpi_adv,
	output logic bpi_ce_n,
	output logic bpi_oe_n,
	output logic bpi_we_n
);
	localparam C_MEM_ADDR_WIDTH = $clog2(8*C_MEM_SIZE/C_MEM_WIDTH);
	localparam C_MEM_ADDR_ADJ_WIDTH = 8 * ((C_MEM_ADDR_WIDTH + 7) / 8);

	logic mode;
	logic read_active, write_active;
	logic enable_read, enable_write;
	logic [4:0] queued_read, queued_write;
	logic [4:0] done_read, done_write;

	logic [C_MEM_ADDR_ADJ_WIDTH-1:0] s_axis_rd_rq_tdata;
	logic [9:0] s_axis_rd_rq_tuser;
	logic s_axis_rd_rq_tvalid, s_axis_rd_rq_tready;

	logic [C_MEM_ADDR_ADJ_WIDTH-1:0] s_axis_wr_rq_tdata;
	logic s_axis_wr_rq_tuser, s_axis_wr_rq_tvalid, s_axis_wr_rq_tready;

	// Coordinator

	enum logic [2:0] {ST_IDLE, ST_READ, ST_WRITE, ST_WR_TO_RD, ST_RD_TO_WR} state;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_IDLE;

			mode <= 1'b0;
			enable_read <= 1'b0;
			enable_write <= 1'b0;
		end else begin
			case(state)
				ST_IDLE: begin
					enable_read <= 1'b0;
					enable_write <= 1'b0;

					if(~read_active & ~write_active) begin
						if(queued_write != 5'd0) begin
							state <= ST_WRITE;
							enable_write <= 1'b1;
						end else if(queued_read != 5'd0) begin
							state <= ST_READ;
							enable_read <= 1'b1;
						end
					end
				end

				ST_READ: begin
					mode <= 1'b0;
					enable_read <= 1'b1;
					enable_write <= 1'b0;

					if(queued_read == 5'd0) begin
						state <= ST_IDLE;
						enable_read <= 1'b0;
					end

					if(queued_write != 5'd0 && done_read >= 5'd16) begin
						state <= ST_RD_TO_WR;
						enable_read <= 1'b0;
					end
				end

				ST_WRITE: begin
					mode <= 1'b1;
					enable_read <= 1'b0;
					enable_write <= 1'b1;

					if(queued_write == 5'd0) begin
						state <= ST_IDLE;
						enable_write <= 1'b0;
					end

					if(queued_read != 5'd0 && done_write >= 5'd16) begin
						state <= ST_WR_TO_RD;
						enable_write <= 1'b0;
					end
				end

				ST_RD_TO_WR: begin
					enable_read <= 1'b0;
					enable_write <= 1'b0;

					if(~read_active & ~write_active) begin
						state <= ST_WRITE;
						mode <= 1'b1;
						enable_write <= 1'b1;
					end
				end

				ST_WR_TO_RD: begin
					enable_read <= 1'b0;
					enable_write <= 1'b0;

					if(~read_active & ~write_active) begin
						state <= ST_READ;
						mode <= 1'b0;
						enable_read <= 1'b1;
					end
				end

				default: begin
					state <= ST_IDLE;
				end
			endcase
		end
	end

	// AR channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			done_read <= 5'd0;
			queued_read <= 5'd0;

			s_axis_rd_rq_tdata <= '0;
			s_axis_rd_rq_tuser <= 10'd0;
			s_axis_rd_rq_tvalid <= 1'b0;
		end else begin
			if(s_axi_arvalid & s_axi_arready) begin
				s_axis_rd_rq_tdata <= {'0, s_axi_araddr[$clog2(C_MEM_SIZE)-1:$clog2(C_MEM_WIDTH/8)]};
				s_axis_rd_rq_tuser[9:2] <= s_axi_arlen;

				if(s_axi_arsize >= $clog2(C_AXI_WIDTH/8)) begin
					s_axis_rd_rq_tuser[1:0] <= 2'b10;
				end else begin
					s_axis_rd_rq_tuser[1:0] <= 2'b00;
				end

				// Unaligned access

				if(s_axi_araddr[$clog2(C_MEM_WIDTH/8)-1:0] != '0) begin
					s_axis_rd_rq_tuser[0] <= 1'b1;
				end

				// Invalid burst size

				if(s_axi_arsize > $clog2(C_AXI_WIDTH/8)) begin
					s_axis_rd_rq_tuser[0] <= 1'b1;
				end

				// Invalid burst mode

				if(s_axi_arburst != 2'd1 && s_axi_arlen != 8'd0) begin
					s_axis_rd_rq_tuser[0] <= 1'b1;
				end

				// Narrow burst

				if(s_axi_arsize != $clog2(C_AXI_WIDTH/8) && s_axi_arlen != 8'd0) begin
					s_axis_rd_rq_tuser[0] <= 1'b1;
				end
			end

			if(s_axi_arready) begin
				s_axis_rd_rq_tvalid <= s_axi_arvalid;
			end

			if((s_axi_arvalid & s_axi_arready) ^ (m_axis_rd_rq_tvalid & m_axis_rd_rq_tready)) begin
				if(s_axi_arvalid & s_axi_arready) begin
					queued_read <= queued_read + 5'd1;
				end else begin
					queued_read <= queued_read - 5'd1;
				end
			end

			if(s_axi_rvalid & s_axi_rready & s_axi_rlast) begin
				if(done_read != '1) begin
					done_read <= done_read + 5'd1;
				end
			end

			if(state != ST_READ) begin
				done_read <= 5'd0;
			end
		end
	end

	always_comb begin
		s_axi_arready = s_axis_rd_rq_tready & ~queued_read[4];
	end

	// AW channel

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			done_write <= 5'd0;
			queued_write <= 5'd0;

			s_axis_wr_rq_tdata <= '0;
			s_axis_wr_rq_tuser <= 10'd0;
			s_axis_wr_rq_tvalid <= 1'b0;
		end else begin
			if(s_axi_awvalid & s_axi_awready) begin
				s_axis_wr_rq_tdata <= {'0, s_axi_awaddr[$clog2(C_MEM_SIZE)-1:$clog2(C_MEM_WIDTH/8)]};
				s_axis_wr_rq_tuser <= 1'b0;

				// Unaligned access

				if(s_axi_awaddr[$clog2(C_MEM_WIDTH/8)-1:0] != '0) begin
					s_axis_wr_rq_tuser <= 1'b1;
				end

				// Invalid burst size

				if(s_axi_awsize > $clog2(C_AXI_WIDTH/8)) begin
					s_axis_wr_rq_tuser <= 1'b1;
				end

				// Invalid burst mode

				if(s_axi_awburst != 2'd1 && s_axi_arlen != 8'd0) begin
					s_axis_wr_rq_tuser <= 1'b1;
				end

				// Narrow burst

				if(s_axi_awsize != $clog2(C_AXI_WIDTH/8) && s_axi_awlen != 8'd0) begin
					s_axis_wr_rq_tuser <= 1'b1;
				end
			end

			if(s_axi_awready) begin
				s_axis_wr_rq_tvalid <= s_axi_awvalid;
			end

			if((s_axi_awvalid & s_axi_awready) ^ (m_axis_wr_rq_tvalid & m_axis_wr_rq_tready)) begin
				if(s_axi_awvalid & s_axi_awready) begin
					queued_write <= queued_write + 5'd1;
				end else begin
					queued_write <= queued_write - 5'd1;
				end
			end

			if(s_axi_bvalid & s_axi_bready) begin
				if(done_write != '1) begin
					done_write <= done_write + 5'd1;
				end
			end

			if(state != ST_WRITE) begin
				done_write <= 5'd0;
			end
		end
	end

	always_comb begin
		s_axi_awready = s_axis_wr_rq_tready & ~queued_write[4];
	end

	// Transaction FIFOs

	logic [C_MEM_ADDR_ADJ_WIDTH-1:0] m_axis_rd_rq_tdata;
	logic [9:0] m_axis_rd_rq_tuser;
	logic m_axis_rd_rq_tvalid, m_axis_rd_rq_tready;

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(16),
		.FIFO_MEMORY_TYPE("distributed"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_MEM_ADDR_ADJ_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(10),
		.USE_ADV_FEATURES("0000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U0
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_axis_rd_rq_tdata),
		.s_axis_tuser(s_axis_rd_rq_tuser),
		.s_axis_tvalid(s_axis_rd_rq_tvalid & ~queued_read[4]),
		.s_axis_tready(s_axis_rd_rq_tready),

		.m_axis_tdata(m_axis_rd_rq_tdata),
		.m_axis_tuser(m_axis_rd_rq_tuser),
		.m_axis_tvalid(m_axis_rd_rq_tvalid),
		.m_axis_tready(m_axis_rd_rq_tready),

		.s_axis_tlast(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

	logic [C_MEM_ADDR_ADJ_WIDTH-1:0] m_axis_wr_rq_tdata;
	logic m_axis_wr_rq_tuser, m_axis_wr_rq_tvalid, m_axis_wr_rq_tready;

	xpm_fifo_axis
	#(
		.CDC_SYNC_STAGES(2),
		.CLOCKING_MODE("common_clock"),
		.ECC_MODE("no_ecc"),
		.FIFO_DEPTH(16),
		.FIFO_MEMORY_TYPE("distributed"),
		.PACKET_FIFO("false"),
		.PROG_EMPTY_THRESH(10),
		.PROG_FULL_THRESH(10),
		.RD_DATA_COUNT_WIDTH(1),
		.RELATED_CLOCKS(0),
		.TDATA_WIDTH(C_MEM_ADDR_ADJ_WIDTH),
		.TDEST_WIDTH(1),
		.TID_WIDTH(1),
		.TUSER_WIDTH(1),
		.USE_ADV_FEATURES("0000"),
		.WR_DATA_COUNT_WIDTH(1)
	)
	U1
	(
		.m_aclk(clk),
		.s_aclk(clk),
		.s_aresetn(rst_n),

		.prog_full_axis(),
		.prog_empty_axis(),

		.s_axis_tdata(s_axis_wr_rq_tdata),
		.s_axis_tuser(s_axis_wr_rq_tuser),
		.s_axis_tvalid(s_axis_wr_rq_tvalid & ~queued_write[4]),
		.s_axis_tready(s_axis_wr_rq_tready),

		.m_axis_tdata(m_axis_wr_rq_tdata),
		.m_axis_tuser(m_axis_wr_rq_tuser),
		.m_axis_tvalid(m_axis_wr_rq_tvalid),
		.m_axis_tready(m_axis_wr_rq_tready),

		.s_axis_tlast(1'b0),
		.s_axis_tdest(1'b0),
		.s_axis_tid(1'b0),
		.s_axis_tkeep(1'b1),
		.s_axis_tstrb(1'b1),

		.injectdbiterr_axis(1'b0),
		.injectsbiterr_axis(1'b0)
	);

	// IO FSMs

	logic [C_MEM_WIDTH-1:0] m_axis_rd_tdata;
	logic m_axis_rd_tvalid;

	logic [C_MEM_ADDR_WIDTH-1:0] s_axis_rd_tdata;
	logic s_axis_rd_tvalid, s_axis_rd_tready;

	logic [C_MEM_WIDTH-1:0] s_axis_wr_tdata;
	logic [C_MEM_ADDR_WIDTH-1:0] s_axis_wr_tdest;
	logic s_axis_wr_tvalid, s_axis_wr_tready;

	bpi_flash_ctrl
	#(
		C_MEM_WIDTH,
		C_MEM_SIZE,

		C_ADDR_TO_CEL_TIME,
		C_OEL_TO_DQ_TIME,
		C_WEL_TO_DQ_TIME,
		C_DQ_TO_WEH_TIME,
		C_IO_TO_IO_TIME
	)
	U2
	(
		.clk(clk),
		.rst_n(rst_n),

		.mode(mode),

		// M_AXIS_RD

		.m_axis_rd_tdata(m_axis_rd_tdata),
		.m_axis_rd_tvalid(m_axis_rd_tvalid),

		// S_AXIS_RD

		.s_axis_rd_tdata(s_axis_rd_tdata),
		.s_axis_rd_tvalid(s_axis_rd_tvalid),
		.s_axis_rd_tready(s_axis_rd_tready),

		// S_AXIS_WR

		.s_axis_wr_tdata(s_axis_wr_tdata),
		.s_axis_wr_tdest(s_axis_wr_tdest),
		.s_axis_wr_tvalid(s_axis_wr_tvalid),
		.s_axis_wr_tready(s_axis_wr_tready),

		// BPI

		.bpi_a(bpi_a),
		.bpi_dq_o(bpi_dq_o),
		.bpi_dq_t(bpi_dq_t),
		.bpi_dq_i(bpi_dq_i),

		.bpi_adv(bpi_adv),
		.bpi_ce_n(bpi_ce_n),
		.bpi_oe_n(bpi_oe_n),
		.bpi_we_n(bpi_we_n)
	);

	bpi_flash_read_fsm
	#(
		C_AXI_WIDTH,
		C_AXI_RD_FIFO_DEPTH,

		C_MEM_WIDTH,
		C_MEM_SIZE
	)
	U3
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(enable_read),
		.active(read_active),

		// S_AXI

		.s_axi_rdata(s_axi_rdata),
		.s_axi_rresp(s_axi_rresp),
		.s_axi_rvalid(s_axi_rvalid),
		.s_axi_rlast(s_axi_rlast),
		.s_axi_rready(s_axi_rready),

		// S_AXIS_RQ

		.s_axis_rq_tdata(m_axis_rd_rq_tdata[C_MEM_ADDR_WIDTH-1:0]),
		.s_axis_rq_tuser(m_axis_rd_rq_tuser),
		.s_axis_rq_tvalid(m_axis_rd_rq_tvalid),
		.s_axis_rq_tready(m_axis_rd_rq_tready),

		// S_AXIS_RD

		.s_axis_rd_tdata(m_axis_rd_tdata),
		.s_axis_rd_tvalid(m_axis_rd_tvalid),

		// M_AXIS_RD

		.m_axis_rd_tdata(s_axis_rd_tdata),
		.m_axis_rd_tvalid(s_axis_rd_tvalid),
		.m_axis_rd_tready(s_axis_rd_tready)
	);

	bpi_flash_write_fsm
	#(
		C_AXI_WIDTH,
		C_AXI_WR_FIFO_DEPTH,

		C_MEM_WIDTH,
		C_MEM_SIZE
	)
	U4
	(
		.clk(clk),
		.rst_n(rst_n),

		.enable(enable_write),
		.enable_fifo(1'b1),
		.active(write_active),

		// S_AXI

		.s_axi_wdata(s_axi_wdata),
		.s_axi_wstrb(s_axi_wstrb),
		.s_axi_wlast(s_axi_wlast),
		.s_axi_wvalid(s_axi_wvalid),
		.s_axi_wready(s_axi_wready),

		.s_axi_bresp(s_axi_bresp),
		.s_axi_bvalid(s_axi_bvalid),
		.s_axi_bready(s_axi_bready),

		// S_AXIS_RQ

		.s_axis_rq_tdata(m_axis_wr_rq_tdata[C_MEM_ADDR_WIDTH-1:0]),
		.s_axis_rq_tuser(m_axis_wr_rq_tuser),
		.s_axis_rq_tvalid(m_axis_wr_rq_tvalid),
		.s_axis_rq_tready(m_axis_wr_rq_tready),

		// M_AXIS_WR

		.m_axis_wr_tdata(s_axis_wr_tdata),
		.m_axis_wr_tdest(s_axis_wr_tdest),
		.m_axis_wr_tvalid(s_axis_wr_tvalid),
		.m_axis_wr_tready(s_axis_wr_tready)
	);
endmodule
