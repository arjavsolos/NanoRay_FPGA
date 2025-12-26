module video_timing (
    input  wire clk_pixel,
    output wire [9:0] sx, sy,        // sx = screen x (0-639), sy = screen y (0-479)
    output wire h_sync, v_sync, de   // de = data enable (are we drawing pixels or invisible borders?)
);
    // setup the 640x480 screen size constants.
    // the screen is actually bigger than 640x480. it has invisible borders called "blanking".
    // ha = horizontal active (640 pixels we can see)
    // hf = front porch (a tiny pause after the line)
    // hs = sync pulse (tells the monitor to go to the next line)
    // ht = total width (800 pixels total, including the invisible parts)
    localparam HA = 640; localparam HF = 16; localparam HS = 96; localparam HT = 800;
    localparam VA = 480; localparam VF = 10; localparam VS = 2;  localparam VT = 525;

    reg [9:0] cx = 0, cy = 0; // these are our counters.

    always @(posedge clk_pixel) begin
        // count the x position (horizontal)
        if (cx == HT-1) begin
            cx <= 0; // we hit the end of the line, reset x to 0
            
            // count the y position (vertical)
            if (cy == VT-1) cy <= 0; // we hit the bottom of the screen, reset y to 0
            else cy <= cy + 1;       // otherwise go to the next line
        end else begin
            cx <= cx + 1; // keep moving right
        end
    end

    // output the current coordinates so our game logic knows where we are
    assign sx = cx;
    assign sy = cy;
    
    // "de" stands for data enable. 
    // if de is 1, we are in the visible part of the screen (draw pixels).
    // if de is 0, we are in the invisible border (draw black).
    assign de = (cx < HA) && (cy < VA);
    
    // sync signals. these are like the carriage return on a typewriter.
    // h_sync tells the monitor "new line coming".
    // v_sync tells the monitor "new frame coming".
    assign h_sync = (cx >= HA + HF) && (cx < HA + HF + HS); 
    assign v_sync = (cy >= VA + VF) && (cy < VA + VF + VS);
endmodule