// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module clk_100M_to_clk_1k (
    input   logic   clk_100M_i,
    input   logic   rst_ni,
    output  logic   clk_1k_o
);

    localparam int COUNTER_RESET = 100000;

    typedef logic [$clog2(COUNTER_RESET):0] counter_t;
    counter_t counter_d, counter_q;

    assign counter_d = (counter_q == (COUNTER_RESET-1)) ? ('0) : (counter_q+1);

    always_ff @(posedge clk_100M_i) begin
        if (!rst_ni) begin
            counter_q <= '0;
        end else begin
            counter_q <= counter_d;
        end
    end

    logic clk_d, clk_q;

    assign clk_d = ( counter_q > (COUNTER_RESET/2));
    assign clk_1k_o = clk_q;

    always_ff @(posedge clk_100M_i) begin
        clk_q <= clk_d;
    end

endmodule
