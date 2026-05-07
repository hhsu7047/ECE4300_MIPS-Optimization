module id_ex_latch (
    input wire clk, rst,
    input wire [1:0] wb_in, input wire [2:0] m_in, input wire [3:0] ex_in,
    input wire [31:0] npc_in, read_data1_in, read_data2_in, sign_ext_in,
    input wire [4:0] instr_2521_in, // Added RS field (bits 25:21)
    input wire [4:0] instr_2016_in, // RT field (bits 20:16)
    input wire [4:0] instr_1511_in, // RD field (bits 15:11)

    output reg [1:0] wb_out, output reg [2:0] m_out, output reg [3:0] ex_out,
    output reg [31:0] npc_out, read_data1_out, read_data2_out, sign_ext_out,
    output reg [4:0] instr_2521_out, // RS field output
    output reg [4:0] instr_2016_out, // RT field output
    output reg [4:0] instr_1511_out  // RD field output
);
    always @(posedge clk) begin
        if (rst) begin
            {wb_out, m_out, ex_out} <= 0;
            {npc_out, read_data1_out, read_data2_out, sign_ext_out} <= 0;
            {instr_2521_out, instr_2016_out, instr_1511_out} <= 0;
        end else begin
            wb_out <= wb_in; 
            m_out  <= m_in; 
            ex_out <= ex_in;
            npc_out        <= npc_in; 
            read_data1_out <= read_data1_in; 
            read_data2_out <= read_data2_in; 
            sign_ext_out   <= sign_ext_in;
            instr_2521_out <= instr_2521_in; // Latch the RS address
            instr_2016_out <= instr_2016_in; 
            instr_1511_out <= instr_1511_in;
        end
    end
endmodule