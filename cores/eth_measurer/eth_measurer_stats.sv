/*
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
*/

module eth_measurer_stats
(
	input logic clk,
	input logic rst,

	input logic tx_begin,
	input logic [13:0] tx_bytes,
	input logic tx_good,
	input logic tx_bad,

	input logic rx_end,
	input logic [13:0] rx_bytes,
	input logic rx_good,
	input logic rx_bad,

	output logic [63:0] total_tx_bytes,
	output logic [63:0] total_tx_pings,
	output logic [63:0] total_tx_good,
	output logic [63:0] total_tx_bad,

	output logic [63:0] total_rx_bytes,
	output logic [63:0] total_rx_pings,
	output logic [63:0] total_rx_good,
	output logic [63:0] total_rx_bad
);
	always_ff @(posedge clk or posedge rst) begin
		if(rst) begin
			total_tx_bytes <= 64'd0;
			total_tx_pings <= 64'd0;
			total_tx_good <= 64'd0;
			total_tx_bad <= 64'd0;

			total_rx_bytes <= 64'd0;
			total_rx_pings <= 64'd0;
			total_rx_good <= 64'd0;
			total_rx_bad <= 64'd0;
		end else begin
			total_tx_bytes <= total_tx_bytes + {50'd0, tx_bytes};
			total_tx_pings <= total_tx_pings + {63'd0, tx_begin};
			total_tx_good <= total_tx_good + {63'd0, tx_good};
			total_tx_bad <= total_tx_bad + {63'd0, tx_bad};

			total_rx_bytes <= total_rx_bytes + {50'd0, rx_bytes};
			total_rx_pings <= total_rx_pings + {63'd0, rx_begin};
			total_rx_good <= total_rx_good + {63'd0, rx_good};
			total_rx_bad <= total_rx_bad + {63'd0, rx_bad};
		end
	end
endmodule
