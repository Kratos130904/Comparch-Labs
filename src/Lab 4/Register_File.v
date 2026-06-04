`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 21:16:37
// Design Name: 
// Module Name: Register_File
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
module Register_File(
    input [3:0] Read_Reg_Num,
    input [3:0] Write_Reg_Num,
    input [7:0] Write_Data,
    output [7:0] Read_Data,
    input reset
);

reg [7:0] RegMemory [15:0]; //16 8-bit registers
integer i;

assign Read_Data = RegMemory[Read_Reg_Num];

always @(*)
begin
    RegMemory[Write_Reg_Num] = Write_Data;
end

always @(negedge reset)
begin

    RegMemory[0] <= 8'h0;
    RegMemory[1] <= 8'h6;
    RegMemory[2] <= 8'h7;
    RegMemory[9] <= 8'h8;
    
    for (i = 3; i < 9; i = i + 1) begin
        RegMemory[i] <= 8'b0;
    end
    
    for (i = 10; i < 16; i = i + 1) begin
        RegMemory[i] <= 8'b0;
    end
end
endmodule