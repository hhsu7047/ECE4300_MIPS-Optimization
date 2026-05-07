`timescale 1ns / 1ps

module ex_mem(
    input wire clk,
    input wire rst,      // <--- ADD THIS
    input wire [1:0] ctlwb_out,
    input wire [2:0] ctlm_out,
    input wire [31:0] adder_out,
    input wire aluzero,
    input wire [31:0] aluout,
    input wire [31:0] readdat2,
    input wire [4:0] muxout,

    output reg [1:0] wb_ctlout,
    output reg branch, memread, memwrite, 
    output reg [31:0] add_result,
    output reg zero,
    output reg [31:0] alu_result,
    output reg [31:0] rdata2out,
    output reg [4:0] five_bit_muxout
);

    // Pipeline registers MUST have a reset to clear the pipe at startup
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Force everything to 0 so the PC-Mux doesn't see "X"
            wb_ctlout       <= 2'b0;
            branch          <= 1'b0;
            memread         <= 1'b0;
            memwrite        <= 1'b0;
            add_result      <= 32'h0;
            zero            <= 1'b0;
            alu_result      <= 32'h0;
            rdata2out       <= 32'h0;
            five_bit_muxout <= 5'h0;
        end else begin
            wb_ctlout       <= ctlwb_out;
            branch          <= ctlm_out[2];
            memread         <= ctlm_out[1];
            memwrite        <= ctlm_out[0];
            add_result      <= adder_out;
            zero            <= aluzero;
            alu_result      <= aluout;
            rdata2out       <= readdat2;
            five_bit_muxout <= muxout;
        end
    end

endmodule