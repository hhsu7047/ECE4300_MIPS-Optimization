module sign_extend (
    input wire [15:0] immediate_in,
    output wire [31:0] immediate_out
);
    // Sign extension: replicate the MSB (bit 15)
    assign immediate_out = {{16{immediate_in[15]}}, immediate_in};
endmodule