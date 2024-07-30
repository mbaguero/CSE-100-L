// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module time_counter (
    input  logic       clk_4_i,
    input  logic       rst_ni,
    input  logic       en_i,
    input  logic       rst_count_i
    output logic [4:0] count_o
);


logic [4:0] t_count_d, t_count_q;

always_ff @(posedge clk_4_i)
    begin
        if (!rst_ni | rst_count_i) begin
            t_count_q <= 0;
        end else begin
            t_count_q <= t_count_d;
        end
    end

always_comb
    begin
        t_count_d = t_count_q;
        if (en_i) begin
            t_count_d = t_count_q + 1;
        end
    end

assign count_o = t_count_q;

endmodule
