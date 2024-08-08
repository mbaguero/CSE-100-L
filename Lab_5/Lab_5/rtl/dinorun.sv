// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

module dinorun import dinorun_pkg::*; (
    input  logic       clk_25_175_i,
    input  logic       rst_ni,

    input  logic       start_i,
    input  logic       up_i,
    input  logic       down_i,

    output logic       digit0_en_o,
    output logic [3:0] digit0_o,
    output logic       digit1_en_o,
    output logic [3:0] digit1_o,
    output logic       digit2_en_o,
    output logic [3:0] digit2_o,
    output logic       digit3_en_o,
    output logic [3:0] digit3_o,

    output logic [3:0] vga_red_o,
    output logic [3:0] vga_green_o,
    output logic [3:0] vga_blue_o,
    output logic       vga_hsync_o,
    output logic       vga_vsync_o
);

// Edge Detector
logic edge_en;
logic edge_dectect;

edge_detector edge_detector_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .data_i(edge_en);

    //outputs
    .edge_o(edge_dectect)
);

// 16 bit LFSR

logic [15:0] rand_num;
logic lfsr_en;

lfsr16 lfsr16_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);
    .next_i(lfsr_en);

    //outputs
    .rand_o(rand_num)
);

// Score Counter

loigc score_counter_en;

score_counter score_counter_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);
    .en_i(score_counter_en);

    .digit0_o(digit0_o);
    .digit1_o(digit1_o);
    .digit2_o(digit2_o);
    .digit3_o(digit3_o)
);

// VGA Timer

logic hsync, vsync;
logic is_visible;
logic [9:0] position_x, position_y;

vga_timer vga_timer_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);

    //outputs
    .hsync_o(hsync);
    .vsync_o(vsync);
    .visible_o(is_visible);
    .position_x_o(position_x);
    .position_y_o(position_o)
);

// Bird Object

logic bird_spawn_en; // = (rand_num[12:8] == 5'b00000 ) ? 1 : 0;
logic bird_pixel;

bird bird_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);
    .spawn_i(bird_spawn_en);
    .next_frame_i(vsync);

    .pixel_x_i(position_x);
    .pixel_y_i(position_y);
    .rand_i(rand_num[1:0]);

    //ouputs
    .pixel_o(bird_pixel);
);

// Cactus Object

logic cactus_spawn_en; // = (rand_num[12:7] == 6'b101010 ) ? 1 : 0;
logic cactus_pixel;

cactus cactus_inst (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);
    .spawn_i(cactus_spawn_en);
    .next_frame_i(vsync);

    .pixel_x_i(position_x);
    .pixel_y_i(position_y);
    .rand_i(rand_num[4:2]);

    //ouputs
    .pixel_o(cactus_pixel);
);

// Dino Object

logic is_hit;
logic dino_pixel;

dino dino_isnt (
    //inputs
    .clk_i(clk_25_175_i);
    .rst_ni(rst_ni);
    .down_i(down_i);
    .up_i(up_i);
    .hit_i(is_hit);
    .next_frame_i(vsync);

    .pixel_x_i(position_x);
    .pixel_y_i(position_y);

    //outputs
    .pixel_o(dino_pixel)
);

// Title Object

logic title_pixel;

title title_inst (
    //inputs
    .pixel_x_i(position_x);
    .pixel_y_i(position_y);

    //ouputs
    .pixel_o(title_pixel);
);

// State Machine

state_t state_d, state_q;

always_ff @(posedge clk_i)
    begin
        if (!rst_ni) begin
            state_q <= STARTING;
        end else begin
            state_q <= state_d;
        end
    end

always_comb
    begin
        state_d = state_q;
        //TODO

        unique case (state_q)
            STARTING: begin

                // TODO

            end
            PLAYING: begin

                // TODO

            end
            HIT: begin

                // TODO

            end
            default: begin
                state_d = STARTING;
            end
        endcase







    end


endmodule
