// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module lfsr (
    input  logic       clk_i,
    input  logic       rst_ni,

    output logic [4:0] rand_o
);

logic [7:0] rnd_d, rnd_q;
logic feedback_xor;

assign feedback_xor = rnd_q[7] ^ rnd_q[6] ^ rnd_q[5] ^ rnd_q[0];
assign rnd_d = {rnd_q[6:0], feedback_xor};

always_ff @(posedge clk_i ) 
    begin
        if (!rst_ni) begin
            rnd_q <=8'b00000001;
        end else begin
            rnd_q <= rnd_d;
        end
    end

assign rand_o = rnd_q[4:0];

endmodule
