// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module lfsr16 (
    input  logic       clk_i,
    input  logic       rst_ni,

    input  logic       next_i,
    output logic [15:0] rand_o
);

logic [15:0] rnd_d, rnd_q;
logic feedback_xor;

assign feedback_xor = rnd_q[15] ^ rnd_q[14] ^ rnd_q[12] ^ rnd_q[3];
assign rnd_d = {rnd_q[14:0], feedback_xor};

always_ff @(posedge clk_i )
    begin
        if (!rst_ni) begin
            rnd_q <= 16'b0000000000000001;
        end else if (next_i) begin
            rnd_q <= rnd_d;
        end
    end

assign rand_o = rnd_q[15:0];

endmodule
