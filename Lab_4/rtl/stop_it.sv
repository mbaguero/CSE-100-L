// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module stop_it import stop_it_pkg::*; (
    input  logic        rst_ni,

    input  logic        clk_4_i,
    input  logic        go_i,
    input  logic        stop_i,
    input  logic        load_i,

    input  logic [15:0] switches_i,
    output logic [15:0] leds_o,

    output logic        digit0_en_o,
    output logic [3:0]  digit0_o,
    output logic        digit1_en_o,
    output logic [3:0]  digit1_o,
    output logic        digit2_en_o,
    output logic [3:0]  digit2_o,
    output logic        digit3_en_o,
    output logic [3:0]  digit3_o
);

// TODO
// Instantiate and drive all required nets and modules

state_t state_d, state_q;
always_ff @(posedge clk_4_i) begin
    if (!rst_ni) begin
        state_q <= WAITING_TO_START;
    end else begin
        state_q <= state_d;
    end
end

always_comb begin
    state_d = state_q;

    // TODO

    unique case (state_q)
        WAITING_TO_START: begin
            // TODO
        end
        STARTING: begin
            // TODO
        end
        DECREMENTING: begin
            // TODO
        end
        WRONG: begin
            // TODO
        end
        CORRECT: begin
            // TODO
        end
        WON: begin
            // TODO
        end
        default: begin
            state_d = WAITING_TO_START;
        end
    endcase
end

endmodule
