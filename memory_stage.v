`timescale 1ns / 1ps

module memory_stage(
    input wire clk,
    input wire  rst,
    input wire [1:0] wb_ctl,    // Write-back control signals
    input wire branch,          // Branch control signal
    input wire memread,         // Memory read control
    input wire memwrite,        // Memory write control
    input wire [31:0] alu_result,
    input wire [31:0] rdata2out, // Data to write to memory (from RT)
    input wire zero,             // Zero flag from ALU
    input wire [4:0] five_bit_muxout, // Destination register index

    output wire [1:0] wb_ctlout,
    output wire [31:0] read_data, // Data read from memory
    output wire [31:0] alu_result_out,
    output wire [4:0] five_bit_muxout_wb,
    output wire pc_src           // High if branch is taken
);

    wire [31:0] mem_data_raw;
    
    // 1. Branch Logic
    // If it's a branch instruction AND the ALU zero flag is set, take the branch
    assign pc_src = branch & zero;

    // 2. Data Memory Instance
    data_memory dmem (
        .clk(clk),
        .address(alu_result),
        .write_data(rdata2out),
        .mem_write(memwrite),
        .mem_read(memread),
        .read_data(mem_data_raw)
    );

    // 3. MEM/WB Pipeline Latch
    // This passes the data to the final stage
    mem_wb pipeline_latch_wb (
        .clk(clk),
        .wb_ctl_in(wb_ctl),
        .mem_data_in(mem_data_raw),
        .alu_result_in(alu_result),
        .muxout_in(five_bit_muxout),
        
        .wb_ctl_out(wb_ctlout),
        .mem_data_out(read_data),
        .alu_result_out(alu_result_out),
        .muxout_out(five_bit_muxout_wb)
    );

endmodule    