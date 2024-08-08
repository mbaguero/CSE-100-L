// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

package dinorun_pkg;

localparam int ScreenWidth = 640;
localparam int ScreenHeight = 480;

localparam int Ground = 400;
localparam int ObstacleInitialX = 640;

typedef enum logic [1:0] {
    STARTING,
    PLAYING,
    HIT
} state_t;


/*
    POSSIBLE STATES:
        01: STARTING
            a) title screen should be visible

            b) dino should be running at initial

            c) no obstacles (obstacle_en LOW)

            d) if start_i go to state PLAYING

        10: PLAYING
            a) title screen should NOT be visible

            b) yes obstacles (obstacle_en HIGH)

            c) if up_i -> dino should jump

            d) if down_i -> dino should duck

            e) if collision -> go to state HIT

        11: HIT
            a) screen should freeze/STOP

            b) 

*/

endpackage
