`timescale 1ns / 1ps

module mips_top(
    input wire clk,
    input wire rst
);

    // --- 1. INTERNAL WIRES ---
    
    // IF to ID
    wire [31:0] if_id_instr, if_id_npc;

    // ID to EX
    wire [1:0]  id_ex_wb_ctl;
    wire [2:0]  id_ex_m_ctl;
    wire [3:0]  id_ex_exec_bundle; 
    wire [31:0] id_ex_npc_wire, id_ex_r1, id_ex_r2, id_ex_imm;
    
    // FORWARDING ADDITION: Need RS address (25:21)
    wire [4:0]  id_ex_rs_addr; 
    wire [4:0]  id_ex_rt_addr, id_ex_rd_addr;

    // EX to MEM
    wire [1:0]  ex_mem_wb_ctl;
    wire        ex_mem_branch, ex_mem_memread, ex_mem_memwrite;
    wire [31:0] ex_mem_branch_target, ex_mem_alu_res, ex_mem_r2_data;
    wire        ex_mem_zero_flag;
    wire [4:0]  ex_mem_dest_reg;
    
    // MEM to IF/WB
    wire   pc_src_final;
    wire [1:0]  mem_wb_ctl_bus;
    wire [31:0] mem_read_data, mem_alu_result;
    wire [4:0]  mem_dest_reg_wb;

    // WB to ID (Feedback Loop)
    wire        wb_reg_write_en;
    wire [31:0] wb_write_data;
    wire [4:0]  wb_write_reg_addr;

    // --- 2. STAGE INSTANTIATIONS ---

    fetch IF_STAGE (
        .clk(clk),
        .rst(rst),
        .ex_mem_pc_src(pc_src_final),
        .ex_mem_npc(ex_mem_branch_target),
        .if_id_instr(if_id_instr),
        .if_id_npc(if_id_npc)
    );

    decode_stage ID_stage (
        .clk(clk),
        .rst(rst),
        .wb_reg_write(wb_reg_write_en),           
        .wb_write_reg_location(wb_write_reg_addr), 
        .mem_wb_write_data(wb_write_data),         
        .if_id_instr(if_id_instr),                 
        .if_id_npc(if_id_npc),                     
        
        .id_ex_wb(id_ex_wb_ctl),
        .id_ex_mem(id_ex_m_ctl),
        .id_ex_execute(id_ex_exec_bundle),
        .id_ex_npc(id_ex_npc_wire),
        .id_ex_readdat1(id_ex_r1),
        .id_ex_readdat2(id_ex_r2),
        .id_ex_sign_ext(id_ex_imm),
        
        // FORWARDING ADJUSTMENT: Added RS output
        .id_ex_instr_bits_25_21(id_ex_rs_addr), 
        .id_ex_instr_bits_20_16(id_ex_rt_addr),
        .id_ex_instr_bits_15_11(id_ex_rd_addr)
    );

    execute_stage EX_STAGE (
        .clk(clk), 
        .rst(rst),
        .wb_ctl(id_ex_wb_ctl),
        .m_ctl(id_ex_m_ctl),
        
        .regdst(id_ex_exec_bundle[3]), 
        .alusrc(id_ex_exec_bundle[0]),
        .aluop(id_ex_exec_bundle[2:1]),
        
        .npcout(id_ex_npc_wire),
        .rdata1(id_ex_r1),
        .rdata2(id_ex_r2),
        .s_extendout(id_ex_imm),
        
        // FORWARDING INPUTS: RS and RT
        .instrout_2521(id_ex_rs_addr), 
        .instrout_2016(id_ex_rt_addr),
        .instrout_1511(id_ex_rd_addr),

        .mem_dest_reg(ex_mem_dest_reg),         // Reg currently in MEM
        .mem_reg_write(ex_mem_wb_ctl[1]),       // RegWrite signal in MEM
        .wb_dest_reg(wb_write_reg_addr),        // Reg currently in WB
        .wb_reg_write(wb_reg_write_en),         // RegWrite signal in WB
        .ex_mem_alu_result(ex_mem_alu_res),     // Bypass value 1
        .final_write_data(wb_write_data),       // Bypass value 2
        
        // Outputs to MEM
        .wb_ctlout(ex_mem_wb_ctl),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .EX_MEM_NPC(ex_mem_branch_target),
        .zero(ex_mem_zero_flag),
        .alu_result(ex_mem_alu_res),
        .rdata2out(ex_mem_r2_data),
        .five_bit_muxout(ex_mem_dest_reg)
    );

    memory_stage MEM_STAGE (
        .clk(clk),
        .rst(rst),
        .wb_ctl(ex_mem_wb_ctl),
        .branch(ex_mem_branch),
        .memread(ex_mem_memread),
        .memwrite(ex_mem_memwrite),
        .alu_result(ex_mem_alu_res),
        .rdata2out(ex_mem_r2_data),
        .zero(ex_mem_zero_flag),
        .five_bit_muxout(ex_mem_dest_reg),
        
        .wb_ctlout(mem_wb_ctl_bus),
        .read_data(mem_read_data),
        .alu_result_out(mem_alu_result),
        .five_bit_muxout_wb(mem_dest_reg_wb),
        .pc_src(pc_src_final) 
    );

    writeback_stage WB_STAGE (
        .wb_ctl(mem_wb_ctl_bus),
        .read_data(mem_read_data),
        .alu_result(mem_alu_result),
        .write_reg_in(mem_dest_reg_wb),
        
        .reg_write_en(wb_reg_write_en),
        .write_data(wb_write_data),
        .write_reg_out(wb_write_reg_addr)
    );

endmodule