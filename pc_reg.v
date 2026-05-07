`timescale 1ns / 1ps
module pc_reg (
    input wire clk,
    input wire rst,      
    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);

    // Use an asynchronous reset for reliability
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h0; // Hard reset to address 0
        end else begin
            pc_out <= pc_in;  // Normal operation
        end
    end

endmodule