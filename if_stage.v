module fetch(
    input wire clk,
    input wire rst,
    input wire ex_mem_pc_src,      
    input wire [31:0] ex_mem_npc,  
    output wire [31:0] if_id_instr,
    output wire [31:0] if_id_npc
);

    // Internal Wires
    wire [31:0] pc_out;     // Current PC address
    wire [31:0] pc_mux;     // Target address from Mux
    wire [31:0] next_pc;    // PC + 1
    wire [31:0] instr_data; // Instruction from memory

    // 1. Mux: Path 1 is Branch, Path 0 is Sequential
    mux_2to1 m0(
        .y(pc_mux),
        .a_true(ex_mem_npc),  
        .b_false(next_pc),    
        .sel(ex_mem_pc_src)
    );

    // 2. PC Register: Synchronous update
    pc_reg pc0(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_mux),
        .pc_out(pc_out)
    );

    
    adder in0(
        .add_in1(pc_out),
        .add_in2(32'd4),  // Manually pass the 4 here
        .add_out(next_pc)
    );

    // 4. Instruction Memory: Asynchronous fetch
    instruction_memory inMem0(
        .addr(pc_out),
        .data(instr_data)
    );

    // 5. IF/ID Latch: Pipeline Register
    ifid_latch ifIdLatch0(
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),        // Passing the incremented PC
        .instr_in(instr_data),  // Passing the fetched instruction
        .pc_out(if_id_npc),
        .instr_out(if_id_instr)
    );

endmodule