`timescale 1ns / 1ps

module writeback_stage( 
    input wire [1:0] wb_ctl,        // Control signals [RegWrite, MemtoReg]
    input wire [31:0] read_data,    // Data from the Memory Stage
    input wire [31:0] alu_result,   // Result from the Execute Stage
    input wire [4:0] write_reg_in,  // Destination register index ($rd or $rt)

    output wire reg_write_en,       // Goes back to Register File "Write Enable"
    output wire [31:0] write_data,  // Goes back to Register File "Write Data"
    output wire [4:0] write_reg_out // Goes back to Register File "Write Register"
);

  
    // Assuming wb_ctl[1] is RegWrite and wb_ctl[0] is MemtoReg
    assign reg_write_en = wb_ctl[1];
    wire mem_to_reg     = wb_ctl[0];

    // If MemtoReg is 1, we write the data from RAM (for LW)
    // If MemtoReg is 0, we write the ALU result (for R-type/I-type)
    assign write_data = (mem_to_reg) ? read_data : alu_result;

    
    assign write_reg_out = write_reg_in;

endmodule