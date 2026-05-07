`timescale 1ns / 1ps

module bottom_mux(
    input wire [4:0] a,    // instrout_1511 (rd)
    input wire [4:0] b,    // instrout_2016 (rt)
    input wire sel,        // regdst control
    output wire [4:0] y
);
    
    assign y = (sel) ? a : b;

endmodule