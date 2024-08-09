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
logic next_frame;

edge_detector edge_detector_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .data_i(vsync_q),

    //outputs
    .edge_o(next_frame)
);

// 16 bit LFSR

logic [15:0] rand_num;
logic lfsr_en;

lfsr16 lfsr16_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(rst_ni),
    .next_i(lfsr_en),

    //outputs
    .rand_o(rand_num)
);

// Score Counter

logic score_counter_en,
logic score_rst_ni,

score_counter score_counter_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(score_rst_ni),
    .en_i(score_counter_en),

    .digit0_o(digit0_o),
    .digit1_o(digit1_o),
    .digit2_o(digit2_o),
    .digit3_o(digit3_o)
);

// VGA Timer

logic hsync_d, hsync_q, vsync_d, vsync_q;
logic is_visible;
logic [9:0] position_x, position_y;

vga_timer vga_timer_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(rst_ni),

    //outputs
    .hsync_o(hsync_d),
    .vsync_o(vsync_d),
    .visible_o(is_visible),
    .position_x_o(position_x),
    .position_y_o(position_y)
);

// Bird Object

logic bird_spawn_en; // = (rand_num[12:8] == 5'b00000 ) ? 1 : 0;
logic bird_pixel;
logic is_frozen;

bird bird_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(rst_ni),
    .spawn_i(bird_spawn_en & !is_visible & !is_frozen),
    .next_frame_i(next_frame & !is_frozen),

    .pixel_x_i(position_x),
    .pixel_y_i(position_y),
    .rand_i(rand_num[1:0]),

    //ouputs
    .pixel_o(bird_pixel)
);

// Cactus Object

logic cactus_spawn_en; // = (rand_num[12:7] == 6'b101010 ) ? 1 : 0;
logic cactus_pixel;

cactus cactus_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(rst_ni),
    .spawn_i(cactus_spawn_en & !is_visible & !is_frozen),
    .next_frame_i(next_frame & !is_frozen),

    .pixel_x_i(position_x),
    .pixel_y_i(position_y),
    .rand_i(rand_num[4:2]),

    //ouputs
    .pixel_o(cactus_pixel)
);

// Dino Object

logic is_hit;
logic dino_pixel;

dino dino_inst (
    //inputs
    .clk_i(clk_25_175_i),
    .rst_ni(rst_ni),
    .down_i(down_i),
    .up_i(up_i),
    .hit_i(is_hit),
    .next_frame_i(next_frame),

    .pixel_x_i(position_x),
    .pixel_y_i(position_y),

    //outputs
    .pixel_o(dino_pixel)
);

// Title Object

logic title_pixel;
logic title_en;

title title_inst (
    //inputs
    .pixel_x_i(position_x),
    .pixel_y_i(position_y),

    //ouputs
    .pixel_o(title_pixel)
);


// RGB Flip Flop

logic [3:0] red_d, red_q, green_d, green_q, blue_d, blue_q;

always_ff @(posedge clk_25_175_i)
    begin
        if (!rst_ni) begin
            vsync_q <= 0;
            hsync_q <= 0;

            red_q <= 4'b0;
            green_q <= 4'b0;
            blue_q <= 4'b0;
        end else begin
            vsync_q <= vsync_d;
            hsync_q <= hsync_d;

            red_q <= red_d;
            green_q <= green_d;
            blue_q <= blue_d;
        end
    end

// Multiplexer to Select Which Pixel to Output
    always_comb begin
        red_d = red_q;
        green_d = green_q; 
        blue_d = blue_q;

        if (bird_pixel) begin
            red_d = 4'b1111; // Example color for bird (bright red)
            green_d = 4'b0000; 
            blue_d = 4'b0000;
        end else if (cactus_pixel) begin
            red_d = 4'b0000;
            green_d = 4'b1111; // Example color for cactus (bright green)
            blue_d = 4'b0000;
        end else if (dino_pixel) begin
            red_d = 4'b0000;
            green_d = 4'b0000; 
            blue_d = 4'b1111;
        end else if (title_pixel & title_en) begin
            red_d = 4'b0011;
            green_d = 4'b0000; 
            blue_d = 4'b1100;
        end else begin
            red_d = 4'b0000; // Background color
            green_d = 4'b0000;
            blue_d = 4'b0000;
        end
    end

always_comb
    begin
        if (is_visible) begin
            vga_red_o = red_q;
            vga_green_o = green_q;
            vga_blue_o = blue_q;
        end else begin
            vga_red_o = 4'b0;
            vga_green_o = 4'b0;
            vga_blue_o = 4'b0;
        end
    end

assign vga_hsync_o = hsync_q;
assign vga_vsync_o = vsync_q;


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

        //object enables
        cactus_spawn_en = (rand_num[12:7] == 6'b101010 ) ? 1 : 0;
        bird_spawn_en = (rand_num[12:8] == 5'b00000 ) ? 1 : 0;

        // dino hit
        is_hit = 0;

        // screen freeze
        is_frozen = 0;

        // score counter en and reset
        score_counter_en = 0;
        score_rst_ni = 0;

        // lfsr en
        lfsr_en = 1;

        // title en
        title_en = 0;

        // digit enables
        digit0_en_o = 0;
        digit1_en_o = 0;
        digit2_en_o = 0;
        digit3_en_o = 0;



        unique case (state_q)
            STARTING: begin
                
                //a) title screen should be visible 

                //b) dino should be running at initial --- DONE

                //c) no obstacles (obstacle_en LOW) --- DONE

                //d) if start_i go to state PLAYING  --- DONE

                cactus_spawn_en = 0;
                bird_spawn_en = 0;
                score_rst_ni = 0; // begin reset to 0000
                score_counter_en = 0;
                title_en = 1;
                is_frozen = 0;

                if (start_i) begin
                    state_d = PLAYING;
                end
            end
            PLAYING: begin
                score_rst_ni = 1;
                score_counter_en = 1;
                title_en = 0;
                
                if (dino_pixel & (bird_pixel | cactus_pixel)) begin
                    is_hit = 1;
                    state_d = HIT;
                end

                
            end
            HIT: begin
                score_counter_en = 0;
                is_frozen = 1;
                title_en = 0;

                if (start_i) begin
                    cactus_spawn_en = 0;
                    bird_spawn_en = 0;
                    score_rst_ni = 0; // begin reset to 0000
                    score_counter_en = 0;
                    is_frozen = 0;
                    state_d = PLAYING;
                end
            end
            default: begin
                state_d = STARTING;
            end
        endcase

    end


endmodule
