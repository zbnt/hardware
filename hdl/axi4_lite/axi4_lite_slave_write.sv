
module axi4_lite_slave_write #(parameter addr_width = 7, parameter data_width = 32)
(
	input logic clk,
	input logic rst_n,

	output logic write_req,
	output logic [addr_width-1:0] write_addr,

	input logic write_ready,
	input logic write_response,

	input logic [addr_width-1:0] s_axi_awaddr,
	input logic [2:0] s_axi_awprot,
	input logic s_axi_awvalid,
	output logic s_axi_awready,

	input logic [data_width-1:0] s_axi_wdata,
	input logic [(data_width/8)-1:0] s_axi_wstrb,
	input logic s_axi_wvalid,
	output logic s_axi_wready,

	output logic [1:0] s_axi_bresp,
	output logic s_axi_bvalid,
	input logic s_axi_bready
);
	enum logic [1:0] {ST_W_WAIT_ADDR, ST_W_WAIT_DATA, ST_W_WAIT_DONE, ST_W_RESPONSE} state, state_next;

	logic awready_next;
	logic [addr_width-1:0] write_addr_next;

	logic wready_next;

	logic bvalid_next;
	logic [1:0] bresp_next;

	always_ff @(posedge clk) begin
		if(~rst_n) begin
			state <= ST_W_WAIT_ADDR;

			s_axi_awready <= 1'b0;
			write_addr <= '0;

			s_axi_wready <= 1'b0;

			s_axi_bvalid <= 1'b0;
			s_axi_bresp <= 2'd0;
		end else begin
			state <= state_next;

			s_axi_awready <= awready_next;
			write_addr <= write_addr_next;

			s_axi_wready <= wready_next;

			s_axi_bvalid <= bvalid_next;
			s_axi_bresp <= bresp_next;
		end
	end

	always_comb begin
		state_next = state;

		awready_next = s_axi_awready;
		write_addr_next = write_addr;

		wready_next = s_axi_wready;

		bvalid_next = s_axi_bvalid;
		bresp_next = s_axi_bresp;

		write_req = 1'b0;

		case(state)
			ST_W_WAIT_ADDR: begin
				awready_next = 1'b1;

				if(rst_n) begin
					if(s_axi_awvalid) begin
						state_next = ST_W_WAIT_DATA;
						write_addr_next = s_axi_awaddr;
						awready_next = 1'b0;
						wready_next = 1'b1;
					end
				end
			end

			ST_W_WAIT_DATA: begin
				if(s_axi_wvalid) begin
					wready_next = 1'd0;
					write_req = 1'b1;

					if(write_ready) begin
						state_next = ST_W_RESPONSE;
						bresp_next = {~write_response, 1'b0};
						bvalid_next = 1'b1;
					end else begin
						state_next = ST_W_WAIT_DONE;
					end
				end
			end

			ST_W_WAIT_DONE: begin
				write_req = 1'b1;

				if(write_ready) begin
					state_next = ST_W_RESPONSE;
					bresp_next = {~write_response, 1'b0};
					bvalid_next = 1'b1;
				end
			end

			ST_W_RESPONSE: begin
				if(s_axi_bready) begin
					state_next = ST_W_WAIT_ADDR;
					awready_next = 1'b1;
					bvalid_next = 1'b0;
				end
			end
		endcase
	end
endmodule
