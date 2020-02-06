`timescale 1ns / 1ps

module tb_loop_compare();
	logic clk = 0;
	logic rst_n = 0;

	logic [7:0] s_axis_tdata = 8'd0;
	logic [32:0] s_axis_tuser = 33'd0;
	logic s_axis_tlast = 1'b0;
	logic s_axis_tvalid = 1'b0;

	logic [7:0] m_axis_tdata;
	logic [33:0] m_axis_tuser;
	logic m_axis_tlast;
	logic m_axis_tvalid;

	logic [31:0] s_axis_tdata_sr = 32'd0;
	logic [131:0] s_axis_tuser_sr = 132'd0;
	logic [3:0] s_axis_tlast_sr = 4'd0;
	logic [3:0] s_axis_tvalid_sr = 4'd0;

	initial begin
		#32ns rst_n = 1'b1;
	end

	always begin
		#4ns clk = ~clk;
	end

	logic [31:0] test_val_a = 32'd0;
	logic [31:0] test_val_b = 32'd0;
	logic [2:0] test_val_c = 3'd0;
	logic [1:0] test_val_d = 2'd0;
	logic running = 1'b0, value_changed = 1'b0;

	always @(posedge clk) begin
		if(~rst_n) begin
			s_axis_tdata_sr <= 32'd0;
			s_axis_tuser_sr <= 132'd0;
			s_axis_tlast_sr <= 4'd0;
			s_axis_tvalid_sr <= 4'd0;

			s_axis_tdata <= 8'd0;
			s_axis_tuser <= 33'd0;
			s_axis_tlast <= 1'b0;
			s_axis_tvalid <= 1'b0;

			running <= 1'b0;
			value_changed <= 1'b0;

			test_val_a <= $urandom;
			test_val_b <= $urandom;
			test_val_c <= $urandom;
			test_val_d <= $urandom;
		end else begin
			s_axis_tdata <= s_axis_tdata_sr[7:0];
			s_axis_tuser <= s_axis_tuser_sr[32:0];
			s_axis_tlast <= s_axis_tlast_sr[0];
			s_axis_tvalid <= s_axis_tvalid_sr[0];

			value_changed <= 1'b0;

			if(~running | (m_axis_tvalid & m_axis_tlast)) begin
				running <= 1'b1;
				value_changed <= 1'b1;

				test_val_a <= $urandom;
				test_val_b <= $urandom;
				test_val_c <= $urandom;
				test_val_d <= $urandom;
			end

			if(value_changed) begin
				if(~test_val_d[0]) begin
					s_axis_tdata_sr <= test_val_a;
					s_axis_tuser_sr <= {8'd0, test_val_b[31:24], 9'b0, test_val_c, test_val_d, 3'b110, 8'd0, test_val_b[23:16], 12'd0, test_val_d, 3'b010, 8'd0, test_val_b[15:8], 12'd0, test_val_d, 3'b010, 8'd0, test_val_b[7:0], 12'd0, test_val_d, 3'b010};
				end else begin
					s_axis_tdata_sr <= {test_val_a[7:0], test_val_a[15:8], test_val_a[23:16], test_val_a[31:24]};
					s_axis_tuser_sr <= {8'd0, test_val_b[7:0], 9'b0, test_val_c, test_val_d, 3'b110, 8'd0, test_val_b[15:8], 12'd0, test_val_d, 3'b010, 8'd0, test_val_b[23:16], 12'd0, test_val_d, 3'b010, 8'd0, test_val_b[31:24], 12'd0, test_val_d, 3'b010};
				end

				s_axis_tlast_sr <= 4'b1000;
				s_axis_tvalid_sr <= 4'b1111;
			end else begin
				s_axis_tdata_sr <= {8'd0, s_axis_tdata_sr[31:8]};
				s_axis_tuser_sr <= {33'd0, s_axis_tuser_sr[131:33]};
				s_axis_tlast_sr <= {1'b0, s_axis_tlast_sr[3:1]};
				s_axis_tvalid_sr <= {1'b0, s_axis_tvalid_sr[3:1]};
			end

			if(m_axis_tvalid & m_axis_tlast) begin
				if(~test_val_d[1]) begin
					$display("U: %d - %d - %d - %d", test_val_a, test_val_b, test_val_c, test_val_d);

					case(test_val_c)
						4'd0: assert(~m_axis_tuser[1] || test_val_a == test_val_b);
						4'd1: assert(~m_axis_tuser[1] || test_val_a > test_val_b);
						4'd2: assert(~m_axis_tuser[1] || test_val_a < test_val_b);
						4'd3: assert(~m_axis_tuser[1] || test_val_a >= test_val_b);
						4'd4: assert(~m_axis_tuser[1] || test_val_a <= test_val_b);
						4'd5: assert(~m_axis_tuser[1] || test_val_a & test_val_b);
						4'd6: assert(~m_axis_tuser[1] || (test_val_a & test_val_b) == test_val_b);
					endcase
				end else begin
					$display("S: %d - %d - %d - %d", $signed(test_val_a), $signed(test_val_b), test_val_c, test_val_d);

					case(test_val_c)
						4'd0: assert(~m_axis_tuser[1] || $signed(test_val_a) == $signed(test_val_b));
						4'd1: assert(~m_axis_tuser[1] || $signed(test_val_a) > $signed(test_val_b));
						4'd2: assert(~m_axis_tuser[1] || $signed(test_val_a) < $signed(test_val_b));
						4'd3: assert(~m_axis_tuser[1] || $signed(test_val_a) >= $signed(test_val_b));
						4'd4: assert(~m_axis_tuser[1] || $signed(test_val_a) <= $signed(test_val_b));
						4'd5: assert(~m_axis_tuser[1] || $signed(test_val_a) & $signed(test_val_b));
						4'd6: assert(~m_axis_tuser[1] || (test_val_a & test_val_b) == test_val_b);
					endcase
				end
			end
		end
	end

	eth_frame_loop_compare #(1) DUT
	(
		.clk(clk),
		.rst_n(rst_n),

		.match_en(1'b1),

		// S_AXIS

		.s_axis_tdata(s_axis_tdata),
		.s_axis_tuser(s_axis_tuser),
		.s_axis_tlast(s_axis_tlast),
		.s_axis_tvalid(s_axis_tvalid),

		// M_AXIS

		.m_axis_tdata(m_axis_tdata),
		.m_axis_tuser(m_axis_tuser),
		.m_axis_tlast(m_axis_tlast),
		.m_axis_tvalid(m_axis_tvalid)
	);
endmodule
