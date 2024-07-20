// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

dv/basys3_7seg_driver_tb.sv
dv/counters_tb.sv
dv/led_shifter_tb.sv
dv/lfsr_tb.sv

dv/lint/verilator.lint

--timing
-j 0
-Wall
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

--timescale 1ms/1ms
