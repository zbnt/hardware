
module axis_fifo
#(
	parameter C_DEPTH = 32,
	parameter C_MEM_TYPE = "block",
	parameter C_CDC_STAGES = 0,

	parameter C_DATA_WIDTH = 32,
	parameter C_DEST_WIDTH = 1,
	parameter C_USER_WIDTH = 1,
	parameter C_ID_WIDTH = 1,

	parameter C_HAS_STRB = 0,
	parameter C_HAS_KEEP = 0,
	parameter C_HAS_DEST = 0,
	parameter C_HAS_USER = 0,
	parameter C_HAS_ID = 0,
	parameter C_HAS_LAST = 0,

	parameter C_ENABLE_S_COUNT = 0,
	parameter C_ENABLE_M_COUNT = 0,
	parameter C_COUNT_WIDTH = 1
)
(
	input logic s_clk,
	input logic s_rst_n,

	output logic s_full,
	output logic [C_COUNT_WIDTH-1:0] s_count,

	input logic [C_DATA_WIDTH-1:0] s_axis_tdata,
	input logic [C_DATA_WIDTH/8-1:0] s_axis_tstrb,
	input logic [C_DATA_WIDTH/8-1:0] s_axis_tkeep,
	input logic [C_DEST_WIDTH-1:0] s_axis_tdest,
	input logic [C_USER_WIDTH-1:0] s_axis_tuser,
	input logic [C_ID_WIDTH-1:0] s_axis_tid,
	input logic s_axis_tlast,
	input logic s_axis_tvalid,
	output logic s_axis_tready,

	input logic m_clk,

	output logic m_empty,
	output logic [C_COUNT_WIDTH-1:0] m_count,

	output logic [C_DATA_WIDTH-1:0] m_axis_tdata,
	output logic [C_DATA_WIDTH/8-1:0] m_axis_tstrb,
	output logic [C_DATA_WIDTH/8-1:0] m_axis_tkeep,
	output logic [C_DEST_WIDTH-1:0] m_axis_tdest,
	output logic [C_USER_WIDTH-1:0] m_axis_tuser,
	output logic [C_ID_WIDTH-1:0] m_axis_tid,
	output logic m_axis_tlast,
	output logic m_axis_tvalid,
	input logic m_axis_tready
);
	localparam C_FIFO_WIDTH = C_DATA_WIDTH
	                        + |C_HAS_STRB * (C_DATA_WIDTH/8)
	                        + |C_HAS_KEEP * (C_DATA_WIDTH/8)
	                        + |C_HAS_DEST * C_DEST_WIDTH
	                        + |C_HAS_USER * C_USER_WIDTH
	                        + |C_HAS_ID   * C_ID_WIDTH
	                        + |C_HAS_LAST;

	// Assign to s_data

	logic [C_DATA_WIDTH   + |C_HAS_STRB * (C_DATA_WIDTH/8) - 1:0] s_data0;
	logic [$bits(s_data0) + |C_HAS_KEEP * (C_DATA_WIDTH/8) - 1:0] s_data1;
	logic [$bits(s_data1) + |C_HAS_DEST * C_DEST_WIDTH     - 1:0] s_data2;
	logic [$bits(s_data2) + |C_HAS_USER * C_USER_WIDTH     - 1:0] s_data3;
	logic [$bits(s_data3) + |C_HAS_ID   * C_ID_WIDTH       - 1:0] s_data4;
	logic [$bits(s_data4) + |C_HAS_LAST - 1:0] s_data5;

	always_comb begin
		s_data0 = {s_axis_tstrb, s_axis_tdata};
		s_data1 = {s_axis_tkeep, s_data0};
		s_data2 = {s_axis_tdest, s_data1};
		s_data3 = {s_axis_tuser, s_data2};
		s_data4 = {s_axis_tid,   s_data3};
		s_data5 = {s_axis_tlast, s_data4};
	end

	// Assign from m_data

	logic [C_FIFO_WIDTH-1:0] m_data[0:6];

	always_comb begin
		m_data[1] = {'0, m_data[0][C_FIFO_WIDTH-1 : C_DATA_WIDTH                  ]};
		m_data[2] = {'0, m_data[1][C_FIFO_WIDTH-1 : |C_HAS_STRB * (C_DATA_WIDTH/8)]};
		m_data[3] = {'0, m_data[2][C_FIFO_WIDTH-1 : |C_HAS_KEEP * (C_DATA_WIDTH/8)]};
		m_data[4] = {'0, m_data[3][C_FIFO_WIDTH-1 : |C_HAS_DEST * C_DEST_WIDTH    ]};
		m_data[5] = {'0, m_data[4][C_FIFO_WIDTH-1 : |C_HAS_USER * C_USER_WIDTH    ]};
		m_data[6] = {'0, m_data[5][C_FIFO_WIDTH-1 : |C_HAS_ID   * C_ID_WIDTH      ]};

		m_axis_tdata = m_data[0];
		m_axis_tstrb = C_HAS_STRB ? m_data[1] : '1;
		m_axis_tkeep = C_HAS_KEEP ? m_data[2] : '1;
		m_axis_tdest = C_HAS_DEST ? m_data[3] : '0;
		m_axis_tuser = C_HAS_USER ? m_data[4] : '0;
		m_axis_tid   = C_HAS_ID   ? m_data[5] : '0;
		m_axis_tlast = C_HAS_LAST ? m_data[6] : '1;
	end

	// XPM FIFO instance

	localparam C_ADV_FEATURES = C_ENABLE_S_COUNT ? (C_ENABLE_M_COUNT ? "1404" : "1004") : "1000";

	always_comb begin
		s_axis_tready = ~s_full;
	end

	if(C_CDC_STAGES < 2) begin
		xpm_fifo_sync
		#(
			.DOUT_RESET_VALUE("0"),
			.ECC_MODE("no_ecc"),
			.FIFO_MEMORY_TYPE(C_MEM_TYPE),
			.FIFO_READ_LATENCY(0),
			.FIFO_WRITE_DEPTH(C_DEPTH),
			.FULL_RESET_VALUE(0),
			.PROG_EMPTY_THRESH(10),
			.PROG_FULL_THRESH(10),
			.RD_DATA_COUNT_WIDTH(C_COUNT_WIDTH),
			.READ_DATA_WIDTH(C_FIFO_WIDTH),
			.READ_MODE("fwft"),
			.USE_ADV_FEATURES(C_ADV_FEATURES),
			.WAKEUP_TIME(0),
			.WRITE_DATA_WIDTH(C_FIFO_WIDTH),
			.WR_DATA_COUNT_WIDTH(C_COUNT_WIDTH)
		)
		U0
		(
			.wr_clk(s_clk),
			.rst(~s_rst_n),

			.din(s_data5),
			.wr_en(s_axis_tvalid),
			.full(s_full),
			.wr_data_count(s_count),

			.dout(m_data[0]),
			.data_valid(m_axis_tvalid),
			.rd_en(m_axis_tready & m_axis_tvalid),
			.empty(m_empty),
			.rd_data_count(m_count),

			.sleep(1'b0),
			.injectdbiterr(1'b0),
			.injectsbiterr(1'b0)
		);
	end else begin
		xpm_fifo_async
		#(
			.CDC_SYNC_STAGES(C_CDC_STAGES),
			.DOUT_RESET_VALUE("0"),
			.ECC_MODE("no_ecc"),
			.FIFO_MEMORY_TYPE(C_MEM_TYPE),
			.FIFO_READ_LATENCY(0),
			.FIFO_WRITE_DEPTH(C_DEPTH),
			.FULL_RESET_VALUE(0),
			.PROG_EMPTY_THRESH(10),
			.PROG_FULL_THRESH(10),
			.RD_DATA_COUNT_WIDTH(C_COUNT_WIDTH),
			.READ_DATA_WIDTH(C_FIFO_WIDTH),
			.READ_MODE("fwft"),
			.RELATED_CLOCKS(0),
			.USE_ADV_FEATURES(C_ADV_FEATURES),
			.WAKEUP_TIME(0),
			.WRITE_DATA_WIDTH(C_FIFO_WIDTH),
			.WR_DATA_COUNT_WIDTH(C_COUNT_WIDTH)
		)
		U0
		(
			.wr_clk(s_clk),
			.rst(~s_rst_n),

			.din(s_data5),
			.wr_en(s_axis_tvalid),
			.full(s_full),
			.wr_data_count(s_count),

			.rd_clk(m_clk),

			.dout(m_data[0]),
			.data_valid(m_axis_tvalid),
			.rd_en(m_axis_tready & m_axis_tvalid),
			.empty(m_empty),
			.rd_data_count(m_count),

			.sleep(1'b0),
			.injectdbiterr(1'b0),
			.injectsbiterr(1'b0)
		);
	end
endmodule
