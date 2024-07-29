// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3_7seg_driver (
    input              clk_1k_i,
    input              rst_ni,

    input  logic       digit0_en_i,
    input  logic [3:0] digit0_i,
    input  logic       digit1_en_i,
    input  logic [3:0] digit1_i,
    input  logic       digit2_en_i,
    input  logic [3:0] digit2_i,
    input  logic       digit3_en_i,
    input  logic [3:0] digit3_i,

    output logic [3:0] anode_o,
    output logic [6:0] segments_o
);


logic [6:0] seg_n;


// TODO

assign dp = 1;

hex7seg hex7seg (
    .d3(digit_q[3]),
    .d2(digit_q[2]),
    .d1(digit_q[1]),
    .d0(digit_q[0]),

    .A(seg_n[0]),
    .B(seg_n[1]),
    .C(seg_n[2]),
    .D(seg_n[3]),
    .E(seg_n[4]),
    .F(seg_n[5]),
    .G(seg_n[6])
);


logic [3:0] digit_d, digit_q;
logic [3:0] anode_d, anode_q;

always_ff @(posedge)
    begin
        if (rst_ni) begin
            digit_q <= 4'b0;
            anode_q <= 4'b0;
        end else begin
            digit_q <= digit_d;
            anode_q <= anode_d;
        end
    end

always_comb
    begin
        if (digit0_en_i) begin
            digit_d = digit0_i;
            anode_d[0] = 0;
        end else if (digit1_en_i) begin
            digit_d = digit1_i;
            anode_d[1] = 0;
        end else if (digit2_en_i) begin
            digit_d = digit2_i;
            anode_d[2] = 0;
        end else if (digit3_en_i) begin
            digit_d = digit3_i;
            anode_d[3] = 0;
        end 
    end

// RIGHT SIDE - Anode0 & Anode1 - GAME COUNTER
// LEFT SIDE - Anode3 & Anode2 - TARGET


assign anode_o = anode_q;
assign segments_o = ~seg_n;

endmodule
