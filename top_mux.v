`timescale 1ns / 1ps

module top_mux(
    input wire [31:0] a,    // Sign-extended Immediate
    input wire [31:0] b,    // Register Data 2 (rt)
    input wire alusrc,      // Control signal (0 = Reg, 1 = Imm)
    output wire [31:0] y
);
    
    assign y = (alusrc) ? a : b;

endmodule