`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 20:47:47
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
    input [1:0] PC,
    input reset,
    output [7:0] Instruction_Code
);

reg [7:0] Mem [3:0]; // memory with 4 locations

// For normal memory read we use the following statement
assign Instruction_Code = Mem[PC];
// reads instruction code specified by PC // BigEndian

// handling reset condition
always @(negedge reset)
begin
    if (reset == 0) // if reset is equal to logic 0
    // Initialize the memory with 3 instructions
    begin
        Mem[0] = 8'h21;
        // mov r2, r1 (0010 0001) // BigEndian style
        
        Mem[1] = 8'h19;
        // mov r1, r9 (0001 1001) // BigEndian style    
    
        Mem[2] = 8'h92;
        // mov r9, r2 (1001 0010) // BigEndian style
    end
end
endmodule