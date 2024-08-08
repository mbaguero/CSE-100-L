// Copyright (c) 2024 Ethan Sifferman.
// All rights reserved. Distribution Prohibited.

// https://vesa.org/vesa-standards/
// http://tinyvga.com/vga-timing
module vga_timer (
    input  logic       clk_i,
    input  logic       rst_ni,
    output logic       hsync_o,
    output logic       vsync_o,
    output logic       visible_o,
    output logic [9:0] position_x_o,
    output logic [9:0] position_y_o
);


//counter
logic [9:0] position_x_d, position_x_q;
logic [9:0] position_y_d, position_y_q;
logic visible_d, visible_q;

always_ff @(posedge clk_i)
    begin
        if (!rst_ni) begin
            position_x_q <= 0;
            position_y_q <= 0;
            visible_q <= 0;
            vsync_q <= 1;
            hsync_q <= 1;
        end else begin
            position_x_q <= position_x_d;
            position_y_q <= position_y_d;
            visible_q <= visible_d;
            vsync_q <= vsync_d;
            hsync_q <= hsync_d;
        end
    end


always_comb
    begin
        position_x_d = position_x_q;
        position_y_d = position_y_q;
        if (position_x_q < 799) begin
            position_x_d = position_x_q + 1;
        end else begin
            position_x_d = 0;
            if (position_y_q < 524) begin
                position_y_d = position_y_q + 1;
            end else begin
                position_y_d = 0;
            end
        end
    end




assign position_x_o = position_x_q;
assign position_y_o = position_y_q;

logic vsync_d, vsync_q;
logic hsync_d, hsync_q;

always_comb begin
    //hsync logic
    if (position_x_o > 655 & position_x_o < 752) begin
        hsync_d = 0;
    end else begin
        hsync_d = 1;
    end
    //vsync logic
    if (position_y_o >= 490 & position_y_o <= 491) begin
        vsync_d = 0;
    end else begin
        vsync_d = 1;
    end
    //is visible logic
    if (position_x_o <= 639 && position_y_o <= 479) begin
        visible_d = 1;
    end else begin
        visible_d = 0;
    end
end

assign vsync_o = vsync_q;
assign hsync_o = hsync_q;
assign visible_o = visible_q;

endmodule
