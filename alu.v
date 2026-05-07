module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  control,
    output reg  [31:0] result,
    output wire        zero
);
    
    parameter ALUand = 3'b000;
    parameter ALUor  = 3'b001;
    parameter ALUadd = 3'b010;
    parameter ALUsub = 3'b110;
    parameter ALUslt = 3'b111;

    // Zero flag logic
    assign zero = (result == 32'b0);

    // Sign bit mismatch logic for SLT
    wire sign_mismatch;
    assign sign_mismatch = a[31] ^ b[31];

    always @(*) begin
        case(control)
            ALUand: result = a & b;
            ALUor:  result = a | b;
            ALUadd: result = a + b;
            ALUsub: result = a - b;
            ALUslt: result = (a < b) ? (1 - sign_mismatch) : (0 + sign_mismatch);
            default: result = 32'hDEADBEEF; //debug
        endcase
    end
endmodule