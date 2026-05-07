`timescale 1ns / 1ps
module forward_mux(
    input wire [31:0] reg_data,      // Data from ID/EX Latch
    input wire [31:0] mem_forward,   // Data from EX/MEM Latch
    input wire [31:0] wb_forward,    // Data from WB Stage (Final Write Data)
    input wire [1:0]  select,        // Control signal from Forwarding Unit
    output reg [31:0] y
);
    always @(*) begin
        case(select)
            2'b00: y = reg_data;     // No Forwarding
            2'b10: y = mem_forward;  // Forward from MEM
            2'b01: y = wb_forward;   // Forward from WB
            default: y = reg_data;
        endcase
    end
endmodule