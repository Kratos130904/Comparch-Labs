`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2026 19:04:24
// Design Name: 
// Module Name: Instruction_Memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module Instruction_Memory(
    input [31:0] PC,
    input reset,
    output [31:0] Instruction_Code
);

reg [7:0] Mem [67:0]; // byte addressable memory with 68 locations

// For normal memory read we use the following statement
assign Instruction_Code = {Mem[PC], Mem[PC+1], Mem[PC+2], Mem[PC+3]};
// reads instruction code specified by PC // BigEndian

// handling reset condition
always @(negedge reset)
begin
    if (reset == 0) // if reset is equal to logic 0
    // Initialize the memory with 4 instructions
    begin
        Mem[0] = 8'hFC; Mem[1] = 8'h00; Mem[2] = 8'h00; Mem[3] = 8'h00;
        // li r0, 0 (1111 1100 0000 0000 0000 0000 0000 0000) // BigEndian style
        
        Mem[4] = 8'hFC; Mem[5] = 8'h80; Mem[6] = 8'h00; Mem[7] = 8'h00;
        // li r4, 0 (1111 1100 1000 0000 0000 0000 0000 0000) // BigEndian style    
    
        Mem[8] = 8'hFD; Mem[9] = 8'h00; Mem[10] = 8'h00; Mem[11] = 8'h00;
        // li r8, 0 (1111 1101 0000 0000 0000 0000 0000 0000) // BigEndian style

        Mem[12] = 8'hFD; Mem[13] = 8'h60; Mem[14] = 8'h00; Mem[15] = 8'h00;
        // li r11, 0 (1111 1101 0110 0000 0000 0000 0000 0000) // BigEndian style
        
        Mem[16] = 8'hFD; Mem[17] = 8'hA0; Mem[18] = 8'h00; Mem[19] = 8'h00;
        // li r13, 0 (1111 1101 1010 0000 0000 0000 0000 0000) // BigEndian style        

        Mem[20] = 8'hFC; Mem[21] = 8'h40; Mem[22] = 8'h00; Mem[23] = 8'h01;
        // li r2, 1 (1111 1100 0100 0000 0000 0000 0000 0001) // BigEndian style

        Mem[24] = 8'hFC; Mem[25] = 8'hA0; Mem[26] = 8'h00; Mem[27] = 8'h02;
        // li r5, 2 (1111 1100 1010 0000 0000 0000 0000 0010) // BigEndian style

        Mem[28] = 8'hFC; Mem[29] = 8'hC0; Mem[30] = 8'h00; Mem[31] = 8'h03;
        // li r6, 3 (1111 1100 1100 0000 0000 0000 0000 0011) // BigEndian style
         
        Mem[32] = 8'hFD; Mem[33] = 8'h20; Mem[34] = 8'h00; Mem[35] = 8'h04;
        // li r9, 4 (1111 1101 0010 0000 0000 0000 0000 0100) // BigEndian style
        
        Mem[36] = 8'hFD; Mem[37] = 8'h40; Mem[38] = 8'h00; Mem[39] = 8'h05;
        // li r10, 5 (1111 1101 0100 0000 0000 0000 0000 0101) // BigEndian style
        
        Mem[40] = 8'hFC; Mem[41] = 8'h20; Mem[42] = 8'h00; Mem[43] = 8'h08;
        // li r1, 8 (1111 1100 0010 0000 0000 0000 0000 1000) // BigEndian style
        
        Mem[44] = 8'h00; Mem[45] = 8'h01; Mem[46] = 8'h10; Mem[47] = 8'h20;
        // add r0, r1, r2 (0000 0000 0000 0001 0001 0000 0010 0000) // BigEndian style
        
        Mem[48] = 8'h00; Mem[49] = 8'h85; Mem[50] = 8'h30; Mem[51] = 8'h22;
        // sub r4, r5, r6 (0000 0000 1000 0101 0011 0000 0010 0010) // BigEndian style
        
        Mem[52] = 8'h01; Mem[53] = 8'h09; Mem[54] = 8'h50; Mem[55] = 8'h24;
        // and r8, r9, r10 (0000 0001 0000 1001 0101 0000 0010 0100) // BigEndian style
        
        Mem[56] = 8'h01; Mem[57] = 8'h28; Mem[58] = 8'h50; Mem[59] = 8'h25;
        // or r9, r8, r10 (0000 0001 0010 1000 0101 0000 0010 0101) // BigEndian style
        
        Mem[60] = 8'h01; Mem[61] = 8'h66; Mem[62] = 8'h01; Mem[63] = 8'h80;
        // sll r11, r6, 6 (0000 0001 0110 0110 0000 0001 1000 0000) // BigEndian style
         
        Mem[64] = 8'h01; Mem[65] = 8'hA9; Mem[66] = 8'h02; Mem[67] = 8'h82;
        // srl r13, r9, 10 (0000 0001 1010 1001 0000 0010 1000 0010) // BigEndian style
    end
end

endmodule