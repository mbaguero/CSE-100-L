// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3 (
    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic btnC,
    input logic btn_en_i,

    output logic [15:0] led_o,
    output logic [3:0] anode_o,
    output logic [6:0] segments_o
);

logic [3:0] operation_i;

always_comb begin
    if (btnU & btn_en_i) begin
        operation_i = 4'b0001; // 
    end else if (btnL & btn_en_i) begin
        operation_i = 4'b0010;
    end else if (btnC & btn_en_i) begin
        operation_i = 4'b0100;
    end else if (btnR) begin
        operation_i = 4'b1000;
    end else begin
        operation_i = 4'b0000;
    end
end

endmodule
