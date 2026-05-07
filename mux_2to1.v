`timescale 1ns / 1ps
module mux_2to1(
    output wire [31:0] y,
    input wire [31:0] a_true,  // Change 'a' to 'a_true'
    input wire [31:0] b_false, // Change 'b' to 'b_false'
    input wire sel
);
    assign y = (sel === 1'b1) ? a_true : b_false;
endmodule