`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 21:24:10
// Design Name: 
// Module Name: ID_WB_Reg
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
module ID_WB_Reg(
    input [7:0] Read_Data,
    input [3:0] Reg,
    output reg [3:0] Write_Reg_Num,
    output reg [7:0] Write_Data,
    input clk
    );
    
always @(posedge clk)
begin
    Write_Data <= Read_Data;
    Write_Reg_Num <= Reg;
end
endmodule
