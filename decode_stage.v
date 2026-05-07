module decode_stage (
    input wire clk, rst,
    input wire wb_reg_write,
    input wire [4:0] wb_write_reg_location,
    input wire [31:0] mem_wb_write_data,
    input wire [31:0] if_id_instr,
    input wire [31:0] if_id_npc,
    
    output wire [1:0] id_ex_wb,
    output wire [2:0] id_ex_mem,
    output wire [3:0] id_ex_execute,
    output wire [31:0] id_ex_npc,
    output wire [31:0] id_ex_readdat1,
    output wire [31:0] id_ex_readdat2,
    output wire [31:0] id_ex_sign_ext,
    
    output wire [4:0] id_ex_instr_bits_25_21,
    output wire [4:0] id_ex_instr_bits_20_16,
    output wire [4:0] id_ex_instr_bits_15_11
);

    

    wire [1:0]  wb_internal;
    wire [2:0]  mem_internal;
    wire [3:0]  ex_internal;
    wire [31:0] read_data1_internal, read_data2_internal, sign_ext_internal;

    // 1. Control Unit
    control_unit cu (
        .opcode(if_id_instr[31:26]),
        .ex_out(ex_internal),
        .m_out(mem_internal),
        .wb_out(wb_internal)
    );

    // 2. Register File
    register reg0 (
        .clk(clk),
        .rst(rst),
        .RegWrite(wb_reg_write),
        .Read_Reg1(if_id_instr[25:21]),
        .Read_Reg2(if_id_instr[20:16]),
        .Write_Reg(wb_write_reg_location),
        .Write_Data(mem_wb_write_data),
        .Read_Data1(read_data1_internal),
        .Read_Data2(read_data2_internal)
    );

    // 3. Sign Extender
    sign_extend se (
        .immediate_in(if_id_instr[15:0]),
        .immediate_out(sign_ext_internal)
    );

    // 4. ID/EX Latch (The pipeline register)
    id_ex_latch iEL0 (
        .clk(clk), .rst(rst),
        .wb_in(wb_internal), .m_in(mem_internal), .ex_in(ex_internal),
        .npc_in(if_id_npc), 
        .read_data1_in(read_data1_internal), 
        .read_data2_in(read_data2_internal), 
        .sign_ext_in(sign_ext_internal),
        
        // --- 2. PASS THE RS BITS INTO THE LATCH ---
        .instr_2521_in(if_id_instr[25:21]), 
        
        .instr_2016_in(if_id_instr[20:16]),
        .instr_1511_in(if_id_instr[15:11]),
        
        .wb_out(id_ex_wb),
        .m_out(id_ex_mem),
        .ex_out(id_ex_execute),
        .npc_out(id_ex_npc),
        .read_data1_out(id_ex_readdat1),
        .read_data2_out(id_ex_readdat2),    
        .sign_ext_out(id_ex_sign_ext),
        
        // --- 3. CONNECT THE RS OUTPUT FROM THE LATCH ---
        .instr_2521_out(id_ex_instr_bits_25_21), 
        
        .instr_2016_out(id_ex_instr_bits_20_16),
        .instr_1511_out(id_ex_instr_bits_15_11)
    );

endmodule