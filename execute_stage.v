`timescale 1ns / 1ps

module execute_stage(
    input wire clk, rst,
    input wire [1:0] wb_ctl, m_ctl,
    input wire regdst, alusrc,
    input wire [1:0] aluop,
    input wire [31:0] npcout, rdata1, rdata2, s_extendout,
    input wire [4:0] instrout_2521, 
    input wire [4:0] instrout_2016, 
    input wire [4:0] instrout_1511, 

    input wire [4:0]  mem_dest_reg,     
    input wire        mem_reg_write,    
    input wire [4:0]  wb_dest_reg,      
    input wire        wb_reg_write,     
    input wire [31:0] ex_mem_alu_result, 
    input wire [31:0] final_write_data,  

    output wire [1:0] wb_ctlout,
    output wire branch, memread, memwrite,
    output wire [31:0] EX_MEM_NPC,
    output wire zero,
    output wire [31:0] alu_result,
    output wire [31:0] rdata2out,
    output wire [4:0] five_bit_muxout
);

    // --- Internal Wires ---
    wire [31:0] adder_out;
    wire [31:0] alu_b_input;
    wire [31:0] alu_out_raw;
    wire [4:0]  mux_dest_out;
    wire [2:0]  alu_control_signal;
    wire        alu_zero_raw;
    
    reg [1:0] forward_a, forward_b;
    wire [31:0] forwarded_r1, forwarded_r2;

    // --- 1. Forwarding Unit Logic ---
    always @(*) begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        if (mem_reg_write && (mem_dest_reg != 0) && (mem_dest_reg == instrout_2521))
            forward_a = 2'b10; 
        else if (wb_reg_write && (wb_dest_reg != 0) && (wb_dest_reg == instrout_2521))
            forward_a = 2'b01; 

        if (mem_reg_write && (mem_dest_reg != 0) && (mem_dest_reg == instrout_2016))
            forward_b = 2'b10; 
        else if (wb_reg_write && (wb_dest_reg != 0) && (wb_dest_reg == instrout_2016))
            forward_b = 2'b01; 
    end

    // --- 2. Forwarding Muxes ---
    forward_mux MUX_FORWARD_A (
        .reg_data(rdata1),
        .mem_forward(ex_mem_alu_result),
        .wb_forward(final_write_data),
        .select(forward_a),
        .y(forwarded_r1)
    );

    forward_mux MUX_FORWARD_B (
        .reg_data(rdata2),
        .mem_forward(ex_mem_alu_result),
        .wb_forward(final_write_data),
        .select(forward_b),
        .y(forwarded_r2)
    );

    // --- 3. Datapath Components ---

    adder branch_adder (
        .add_in1(npcout),
        .add_in2(s_extendout << 2),
        .add_out(adder_out)
    );

    // : ALU Source Mux (Replaces top_mux)
    // If alusrc is 1, we use the Immediate (s_extendout). 
    // If alusrc is 0, we use the forwarded register data.
    assign alu_b_input = (alusrc) ? s_extendout : forwarded_r2;

    alu_control alu_ctrl_unit (
        .funct(s_extendout[5:0]),
        .aluop(aluop),
        .select(alu_control_signal)
    );

    alu main_alu (
        .a(forwarded_r1),
        .b(alu_b_input),
        .control(alu_control_signal),
        .result(alu_out_raw),
        .zero(alu_zero_raw)
    );

    // FIX 2: RegDst Mux logic check
    // Standard MIPS: RegDst=1 selects RD (bits 15-11). RegDst=0 selects RT (bits 20-16).
    assign mux_dest_out = (regdst) ? instrout_1511 : instrout_2016;

    // --- 4. Pipeline Latch ---
    ex_mem pipeline_latch (
        .clk(clk),
        .rst(rst),                
        .ctlwb_out(wb_ctl),
        .ctlm_out(m_ctl),
        .adder_out(adder_out),
        .aluzero(alu_zero_raw),
        .aluout(alu_out_raw),
        .readdat2(forwarded_r2), 
        .muxout(mux_dest_out),
        
        .wb_ctlout(wb_ctlout),
        .branch(branch),
        .memread(memread),
        .memwrite(memwrite),
        .add_result(EX_MEM_NPC),
        .zero(zero),
        .alu_result(alu_result),
        .rdata2out(rdata2out),
        .five_bit_muxout(five_bit_muxout)
    );

endmodule