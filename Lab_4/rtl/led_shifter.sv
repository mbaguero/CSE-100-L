// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module led_shifter (
    input  logic        clk_i,
    input  logic        rst_ni,

    input  logic        shift_i,

    input  logic [15:0] switches_i,
    input  logic        load_i,

    input  logic        off_i,
    output logic [15:0] leds_o
);

logic [15:0] shift_reg_d, shift_reg_q;


always_ff @(posedge clk_i)
    begin
        if (!rst_ni) begin
            shift_reg_q <= 16'b0;
        end else begin
            shift_reg_q <= shift_reg_d;
        end
    end

always_comb
    begin
        shift_reg_d = shift_reg_q;
        leds_o = 16'b0;
        
        if (shift_i) begin
            shift_reg_d = {shift_reg_q[14:0], 1'b1};
        end else if (load_i) begin
            shift_reg_d = switches_i;
        end else if (off_i) begin
            leds_o = 16'b0;
        end
    end

assign leds_o = shift_reg_q;

endmodule
