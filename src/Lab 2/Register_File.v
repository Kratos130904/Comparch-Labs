`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2026 18:27:26
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
    input [4:0] Read_Reg_Num_1,
    input [4:0] Read_Reg_Num_2,
    input [4:0] Write_Reg_Num,
    input [31:0] Write_Data,
    output [31:0] Read_Data_1,
    output [31:0] Read_Data_2,
    input RegWrite,
    input clk,
    input reset
);

reg [31:0] RegMemory [31:0]; //32 32-bit registers
integer i;

assign Read_Data_1 = RegMemory[Read_Reg_Num_1];
assign Read_Data_2 = RegMemory[Read_Reg_Num_2];

always @(posedge clk)
begin 
    if (RegWrite) begin
        RegMemory[Write_Reg_Num] <= Write_Data;
    end
end
    
always @(negedge reset)
begin
    RegMemory[0] <= 32'd0;
    RegMemory[1] <= 32'd1;
    RegMemory[2] <= 32'd4;
    RegMemory[3] <= 32'd16;
    for (i = 4; i < 32; i = i + 1) begin
        RegMemory[i] <= 32'b0;
    end
end
endmodule