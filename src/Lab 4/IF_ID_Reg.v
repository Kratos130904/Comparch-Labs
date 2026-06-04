`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 21:23:43
// Design Name: 
// Module Name: IF_ID_Reg
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
module IF_ID_Reg(
    input [7:0] Instruction_Code,
    output reg [3:0] Read_Reg_Num,
    output reg [3:0] Reg,
    input clk
    );
    
always @(posedge clk)
begin
    Read_Reg_Num <= Instruction_Code[3:0];
    Reg <= Instruction_Code[7:4];
end
endmodule
