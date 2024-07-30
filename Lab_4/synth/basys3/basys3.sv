// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3 (
    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic btnC,

    output logic [15:0] led_o,
    output logic [3:0] anode_o,
    output logic [6:0] segments_o
);

logic go_i, stop_i, stop_i, rst_ni;
logic btn_en_i;



always_comb begin
    if (btnU & btn_en_i) begin
        stop_i = 1;
    end else if (btnL & btn_en_i) begin
        load_i = 1;
    end else if (btnC & btn_en_i) begin
        go_i = 1;
    end else if (btnR) begin
        rst_ni = 1; // rst_ni
    end else begin
        stop_i = 0;
        load_i = 0;
        go_i = 0;
        rst_ni = 0;
    end
end

endmodule
