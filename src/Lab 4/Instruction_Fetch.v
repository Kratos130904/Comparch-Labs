`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 20:59:47
// Design Name: 
// Module Name: Instruction_Fetch
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
module Instruction_Fetch(
    input clk,
    input reset,
    output wire [7:0] Instruction_Code
);

reg [1:0] PC;

// Instantiate the Instruction memory here
Instruction_Memory IM2 (
    .PC(PC),
    .reset(reset),
    .Instruction_Code(Instruction_Code)
);

always @(posedge clk, negedge reset)
// at posedge of clock or when reset == 0
begin
    // if reset is equal to 0 then initialize PC with 0
    if (reset == 0)
        PC <= 0;
    else        // else increment PC by 1 at every positive edge of clock
        PC <= PC + 1;
end
endmodule