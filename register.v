`timescale 1ns / 1ps
module register(
    input wire clk,
    input wire rst,
    input wire RegWrite,        
    input wire [4:0] Read_Reg1, // instruction[25:21]
    input wire [4:0] Read_Reg2, // instruction[20:16]
    input wire [4:0] Write_Reg, // From Mem/WB Latch
    input wire [31:0] Write_Data, // From WB Mux
    output wire [31:0] Read_Data1,
    output wire [31:0] Read_Data2
);
    // Internal storage for 32 bit registers
    reg [31:0] registers [31:0];
    integer i;

    // Synchronous Write: Happens on the clock edge
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) 
                registers[i] <= 32'b0;
        end else if (RegWrite && Write_Reg != 5'd0) begin
            registers[Write_Reg] <= Write_Data;
        end
    end

    // Asynchronous Read: Happens instantly when address changes
    assign Read_Data1 = (Read_Reg1 == 5'd0) ? 32'h0 : registers[Read_Reg1];
    assign Read_Data2 = (Read_Reg2 == 5'd0) ? 32'h0 : registers[Read_Reg2];

endmodule


