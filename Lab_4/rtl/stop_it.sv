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

//TIME COUNTER
logic time_en;
logic [4:0] time_count;
logic rst_n_count;

time_counter time_counter_inst(
    //inputs
    .rst_ni(rst_n_count),
    .clk_4_i(clk_4_i),
    .en_i(time_en),

    //outputs
    .count_o(time_count)
);

//GAME COUNTER
logic game_en;
logic [4:0] game_count;
logic rst_n_game_count;

game_counter game_counter_inst(
    //inputs
    .rst_ni(rst_n_game_count),
    .clk_4_i(clk_4_i),
    .en_i(game_en),

    //outputs
    .count_o(game_count)
);

//LED SHIFTER
logic shift_left;
logic led_off;

led_shifter led_shifter_inst(
    //inputs
    .clk_i(clk_4_i),
    .rst_ni(rst_ni),
    .shift_i(shift_left),
    .switches_i(switches_i),
    .load_i(load_i),
    .off_i(led_off),

    //outputs
    .leds_o(leds_o)
);

//LINEAR FEEDBACK SHIFT REGISTER
logic [4:0] rand_target_num;
logic lfsr_en;

lfsr lfsr_inst(
    //inputs
    .clk_i(clk_4_i),
    .rst_ni(rst_ni),
    .next_i(lfsr_en),

    //outputs
    .rand_o(rand_target_num)
);


//STATE MACHINE
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

    //timer resets
    rst_n_count = 1;
    rst_n_game_count = 1;

    //timer enables
    time_en =  0;
    game_en = 0;

    //rand en
    lfsr_en = 1;

    shift_left = 0;

    led_off = 0;

    //digits
    digit0_en_o = 0;
    digit0_o = 0;
    digit1_en_o = 0;
    digit1_o = 0;
    digit2_en_o = 0;
    digit2_o = 0;
    digit3_en_o = 0;
    digit3_o = 0;

    unique case (state_q)
        WAITING_TO_START: begin
            rst_n_count = 0;
            rst_n_game_count = 0;
            time_en = 0;
            game_en = 0;
            lfsr_en = 1;

            digit0_en_o = 1;
            digit0_o = game_count[3:0];
            digit1_en_o = 1;
            digit1_o = {3'b0, game_count[4]};

            if (go_i) begin
                state_d = STARTING;
            end else if (!rst_ni) begin
                state_d = WAITING_TO_START;
            end else begin
                state_d = WAITING_TO_START;
            end
        end
        STARTING: begin
            lfsr_en = 0;
            rst_n_count = 1;
            rst_n_game_count = 1;
            time_en = 1;
            game_en = 0;
            digit0_en_o = 1;
            digit0_o = game_count[3:0];
            digit1_en_o = 1;
            digit1_o = {3'b0, game_count[4]};
            digit2_en_o = 1;
            digit2_o = rand_target_num[3:0];
            digit3_en_o = 1;
            digit3_o = {3'b0, rand_target_num[4]};

            if (time_count <= 6) begin
                if (!rst_ni) begin
                    state_d = WAITING_TO_START;
                end
            end else begin
                rst_n_count = 0;
                rst_n_game_count = 0;
                time_en = 0;
                state_d = DECREMENTING;
            end
        end
        DECREMENTING: begin
            lfsr_en = 0;
            rst_n_count = 1;
            rst_n_game_count = 1;

            digit0_en_o = 1;
            digit0_o = game_count[3:0];
            digit1_en_o = 1;
            digit1_o = {3'b0, game_count[4]};
            digit2_en_o = 1;
            digit2_o = rand_target_num[3:0];
            digit3_en_o = 1;
            digit3_o = {3'b0, rand_target_num[4]};

            game_en = 1;

            if (stop_i) begin
                game_en = 0;
                if (rand_target_num == game_count) begin
                    state_d = CORRECT;
                end else if (rand_target_num != game_count) begin
                    state_d = WRONG;
                end
            end else if (!rst_ni) begin
                state_d = WAITING_TO_START;
            end else begin
                state_d = DECREMENTING;
            end
        end
        WRONG: begin
            if (time_count != 0) begin
                rst_n_count = 0;
            end

            rst_n_count = 1;
            rst_n_game_count = 1;
            time_en = 1;
            lfsr_en = 0;

            if (time_count <= 14) begin
                if(time_count % 2) begin
                    digit0_en_o = 1;
                    digit0_o = game_count[3:0];
                    digit1_en_o = 1;
                    digit1_o = {3'b0, game_count[4]};
                    digit2_en_o = 0;
                    digit2_o = rand_target_num[3:0];
                    digit3_en_o = 0;
                    digit3_o = {3'b0, rand_target_num[4]};
                end else begin
                    digit0_en_o = 0;
                    digit0_o = game_count[3:0];
                    digit1_en_o = 0;
                    digit1_o = {3'b0, game_count[4]};
                    digit2_en_o = 1;
                    digit2_o = rand_target_num[3:0];
                    digit3_en_o = 1;
                    digit3_o = {3'b0, rand_target_num[4]};
                end

                if (time_count >= 15) begin
                    time_en = 0;
                    state_d = WAITING_TO_START;
                end
                if (!rst_ni) begin
                    state_d = WAITING_TO_START;
                end
            end else begin
                time_en = 0;
                state_d = WAITING_TO_START;
            end
        end
        CORRECT: begin
            if (time_count != 0) begin
                rst_n_count = 0;
            end
            rst_n_count = 1;
            rst_n_game_count = 1;
            time_en = 1;
            lfsr_en = 0;

            if (time_count <= 14) begin
                if (time_count % 2) begin
                    digit0_en_o = 1;
                    digit0_o = game_count[3:0];
                    digit1_en_o = 1;
                    digit1_o = {3'b0, game_count[4]};
                    digit2_en_o = 1;
                    digit2_o = rand_target_num[3:0];
                    digit3_en_o = 1;
                    digit3_o = {3'b0, rand_target_num[4]};
                end else begin
                    digit0_en_o = 0;
                    digit0_o = game_count[3:0];
                    digit1_en_o = 0;
                    digit1_o = {3'b0, game_count[4]};
                    digit2_en_o = 0;
                    digit2_o = rand_target_num[3:0];
                    digit3_en_o = 0;
                    digit3_o = {3'b0, rand_target_num[4]};
                end

                if (!rst_ni) begin
                    state_d = WAITING_TO_START;
                end
            end else begin
                time_en = 0;
                shift_left = 1;
                if (leds_o == 65535) begin
                    rst_n_count = 0;
                    rst_n_game_count = 0;
                    state_d = WON;
                end else begin
                    state_d = WAITING_TO_START;
                end
            end
        end
        WON: begin
            rst_n_count = 1;
            rst_n_game_count = 1;
            time_en = 1;
            lfsr_en = 0;


            if (time_count % 2) begin
                led_off = 0;
            end else begin
                led_off = 1;
            end

            if (!rst_ni) begin
                state_d = WAITING_TO_START;
            end
        end
        default: begin
            state_d = WAITING_TO_START;
        end
    endcase
end

endmodule
