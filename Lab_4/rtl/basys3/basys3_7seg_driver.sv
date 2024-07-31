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

logic [3:0] digit_i;

hex7seg hex7seg_inst (
    .d3(digit_i[3]),
    .d2(digit_i[2]),
    .d1(digit_i[1]),
    .d0(digit_i[0]),

    .A(seg_n[0]),
    .B(seg_n[1]),
    .C(seg_n[2]),
    .D(seg_n[3]),
    .E(seg_n[4]),
    .F(seg_n[5]),
    .G(seg_n[6])
);

logic [3:0] count_d, count_q;

always_ff @(posedge clk_1k_i)
    begin
        if(!rst_ni) begin
            count_q <= 2'b00;
        end else begin
            count_q <= count_d;
        end
    end

assign count_d = count_q + 1;

always_comb
    begin
        //seg_n = 7'b1111111;
        anode_o = 4'b1111;
        digit_i = 4'b0000;
        case (count_q)
            2'b00: begin
                if (digit0_en_i) begin
                    digit_i = digit0_i;
                    anode_o = 4'b1110;
                    //seg_n = 7'b0000000;
                end else begin
                    anode_o = 4'b1111;
                end
            end
            2'b01: begin
                if (digit1_en_i) begin
                    digit_i = digit1_i;
                    anode_o = 4'b1101;
                    //seg_n = 7'b0000000;
                end else begin
                    anode_o = 4'b1111;
                end
            end
            2'b10: begin
                if (digit2_en_i) begin
                    digit_i = digit2_i;
                    anode_o = 4'b1011;
                    //seg_n = 7'b0000000;
                end else begin
                    anode_o = 4'b1111;
                end
            end
            2'b11: begin
                if (digit3_en_i) begin
                    digit_i = digit3_i;
                    anode_o = 4'b0111;
                    //seg_n = 7'b0000000;
                end else begin
                    anode_o = 4'b1111;
                end
            end
            default: begin
                digit_i = 4'b0000;
                anode_o = 4'b1111;
            end
        endcase
    end

always_comb
    begin
        if (anode_o == 4'b1111) begin
            segments_o = 7'b1111111;
        end else begin
            segments_o = ~seg_n;
        end
    end

endmodule
