`timescale 1ns / 1ps

module alu_control(
    input wire [5:0] funct,
    input wire [1:0] aluop,
    output reg [2:0] select
);
    // Parameters for ALU Operations
    parameter ALUand = 3'b000;
    parameter ALUor  = 3'b001;
    parameter ALUadd = 3'b010;
    parameter ALUsub = 3'b110;
    parameter ALUslt = 3'b111;
    parameter ALUx   = 3'b011; // don't care

    always @(*) begin
        case (aluop)
            2'b00: select = ALUadd; // LW/SW use Addition
            2'b01: select = ALUsub; // BEQ uses Subtraction
            2'b10: begin            // R-type: Look at Funct field
                case (funct)
                    6'b100000: select = ALUadd;
                    6'b100010: select = ALUsub;
                    6'b100100: select = ALUand;
                    6'b100101: select = ALUor;
                    6'b101010: select = ALUslt;
                    default:   select = ALUx;
                endcase
            end
            default: select = ALUx;
        endcase
    end
endmodule