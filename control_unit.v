module control_unit (
    input wire [5:0] opcode,
    output reg [3:0] ex_out, // {RegDst, ALUOp[1:0], ALUSrc}
    output reg [2:0] m_out,  // {Branch, MemRead, MemWrite}
    output reg [1:0] wb_out  // {RegWrite, MemtoReg}
);
    always @(*) begin
        case (opcode)
            6'b000000: begin // R-Format
                ex_out = 4'b1_10_0; m_out = 3'b0_0_0; wb_out = 2'b1_0;
            end
            6'b100011: begin // LW
                ex_out = 4'b0_00_1; m_out = 3'b0_1_0; wb_out = 2'b1_1;
            end
            6'b101011: begin // SW
                ex_out = 4'b0_00_1; m_out = 3'b0_0_1; wb_out = 2'b0_0;
            end
            6'b000100: begin // BEQ
                ex_out = 4'b0_01_0; m_out = 3'b1_0_0; wb_out = 2'b0_0;
            end
            default: begin
                ex_out = 4'b0_00_0; m_out = 3'b0_0_0; wb_out = 2'b0_0;
            end
        endcase
    end
endmodule