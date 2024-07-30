// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module basys3 (
    input logic clk_100,

    input logic btnU,
    input logic btnL,
    input logic btnR,
    input logic btnC,

    output logic [15:0] led_o,
    output logic [3:0] anode_o,
    output logic dp,
    output logic [6:0] segments_o
);

logic go_i, stop_i, load_i, rst_ni;



always_comb begin
    go_i = 0;
    stop_i = 0;
    load_i = 0;
    rst_ni = 0;
    
    if (btnU) begin
        stop_i = 1'b1;
    end else if (btnL) begin
        load_i = 1'b1;
    end else if (btnC) begin
        go_i = 1'b1;
    end else if (btnR) begin
        rst_ni = 1'b1;
    end else begin
        stop_i = 0;
        load_i = 0;
        go_i = 0;
        //rst_ni = 0;
    end
end


logic clk_4;

clk_100M_to_clk_4 clk_100M_to_clk_4_inst(
    .clk_100M_i(clk_100),
    .rst_ni(rst_ni),

    .clk_4_o(clk_4)
);

logic [15:0] switches_load = 16'b1;
logic        digit0_en_o;
logic [3:0]  digit0_o;
logic        digit1_en_o;
logic [3:0]  digit1_o;
logic        digit2_en_o;
logic [3:0]  digit2_o;
logic        digit3_en_o;
logic [3:0]  digit3_o;

stop_it stop_it_inst(
    //inputs
    .rst_ni(rst_ni),

    .clk_4_i(clk_4),
    .go_i(go_i),
    .stop_i(stop_i),
    .load_i(load_i),

    .switches_i(switches_load),
    //ouputs
    .leds_o(led_o),
    .digit0_en_o(digit0_en_o),
    .digit0_o(digit0_o),
    .digit1_en_o(digit1_en_o),
    .digit1_o(digit1_o),
    .digit2_en_o(digit2_en_o),
    .digit2_o(digit2_o),
    .digit3_en_o(digit3_en_o),
    .digit3_o(digit3_o)
);

logic clk_1k;

clk_100M_to_clk_1k clk_100M_to_clk_1k_inst(
    .clk_100M_i(clk_100),
    .rst_ni(rst_ni),

    .clk_1k_o(clk_1k)
);


basys3_7seg_driver basys3_7seg_driver_inst(
    //inputs
    .clk_1k_i(clk_1k),
    .rst_ni(rst_ni),

    .digit0_en_i(digit0_en_o),
    .digit0_i(digit0_o),
    .digit1_en_i(digit1_en_o),
    .digit1_i(digit1_o),
    .digit2_en_i(digit2_en_o),
    .digit2_i(digit2_o),
    .digit3_en_i(digit3_en_o),
    .digit3_i(digit3_o),

    //ouputs
    .dp(dp),
    .anode_o(anode_o),
    .segments_o(segments_o)
);


endmodule
