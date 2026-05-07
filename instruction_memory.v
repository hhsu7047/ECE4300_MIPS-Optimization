`timescale 1ns / 1ps
module instruction_memory (
    input wire [31:0] addr,    
    output wire [31:0] data    
);
    
    reg [31:0] mem [0:63]; 

   initial begin
    $readmemb("instr.mem",mem);
end
    

    //2 bits 
    assign data = mem[addr >> 2]; 
endmodule