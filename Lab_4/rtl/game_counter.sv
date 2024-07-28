// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module game_counter (
    input  logic       clk_4_i,
    input  logic       rst_ni,
    input  logic       en_i,
    output logic [4:0] count_o
);

logic [4:0] count_d, count_q;

always_ff @(posedge clk_4_i)
    begin
        if (!rst_ni) begin
            count_q <= 5'b11111;
        end else if (en_i) begin
            count_q <= count_d;
        end
    end

always_comb
    begin
        count_d = count_q - 1;
    end

/*
always_comb
    begin
        if (en_i) begin
            count_d = count_q - 1;
        end else begin
            count_d = count_q;
        end
    end*/

assign count_o = count_q;

endmodule
