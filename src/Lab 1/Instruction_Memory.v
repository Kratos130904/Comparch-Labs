`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 21:29:22
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

reg [7:0] Mem [36:0]; // byte addressable memory with 37 locations

// For normal memory read we use the following statement
assign Instruction_Code = {Mem[PC], Mem[PC+1], Mem[PC+2], Mem[PC+3]};
// reads instruction code specified by PC // BigEndian

// handling reset condition
always @(reset)
begin
    if (reset == 0) // if reset is equal to logic 0
    // Initialize the memory with 4 instructions
    begin
        Mem[0] = 8'h84; Mem[1] = 8'h04; Mem[2] = 8'h12; Mem[3] = 8'h32;
        // First 32-bit location with data 84041232 hexadecimal // BigEndian style

        Mem[4] = 8'h25; Mem[5] = 8'h43; Mem[6] = 8'h17; Mem[7] = 8'h89;
        // Second 32-bit location with data 25431789 hexadecimal // BigEndian style

        // Similar fill for two more locations
        Mem[8] = 8'h21; Mem[9] = 8'h53; Mem[10] = 8'h67; Mem[11] = 8'h19;
         
        Mem[12] = 8'h22; Mem[13] = 8'h47; Mem[14] = 8'h13; Mem[15] = 8'h56;
    end
end

endmodule