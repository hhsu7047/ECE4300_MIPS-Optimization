module ifid_latch (
    input wire clk,
    input wire rst,              // Added reset to match your fetch module
    input wire [31:0] instr_in,
    input wire [31:0] pc_in,     // Renamed to match .pc_in(next_pc) in fetch.v
    output reg [31:0] instr_out,
    output reg [31:0] pc_out     // Renamed to match .pc_out(if_id_npc) in fetch.v
);

    always @(posedge clk) begin
        if (rst) begin
            // Clear the pipeline register on reset
            instr_out <= 32'h0;
            pc_out    <= 32'h0;
        end else begin
            // Normal operation: Pass data on clock edge
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
    end

endmodule