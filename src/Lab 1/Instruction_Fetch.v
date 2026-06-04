`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2026 23:25:33
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
    output wire [31:0] Instruction_Code
);

reg [31:0] PC;

// Instantiate the Instruction memory here
Instruction_Memory A3 (
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
    else        // else increment PC by 4 at every positive edge of clock
        PC <= PC + 4;
end

endmodule