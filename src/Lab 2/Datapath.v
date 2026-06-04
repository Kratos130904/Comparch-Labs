`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 16:26:07
// Design Name: 
// Module Name: Datapath
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
module Datapath(
    input [4:0] Read_Reg_Num_1,
    input [4:0] Read_Reg_Num_2,
    input [4:0] Write_Reg_Num,
    input [3:0] ALU_control_lines,
    input RegWrite,
    input clk,
    input reset,
    output zero
    );

    wire [31:0] Read_Data_1;
    wire [31:0] Read_Data_2;
    wire [31:0] Write_Data;
    
    //Instantiate Register_File 
    Register_File R1 (
        .Read_Reg_Num_1(Read_Reg_Num_1),
        .Read_Reg_Num_2(Read_Reg_Num_2),
        .Write_Reg_Num(Write_Reg_Num),
        .Write_Data(Write_Data),
        .Read_Data_1(Read_Data_1),
        .Read_Data_2(Read_Data_2),
        .RegWrite(RegWrite),
        .clk(clk),
        .reset(reset)
    );
    
    //Instantiate ALU
    ALU A1 (
        .A(Read_Data_1),
        .B(Read_Data_2),
        .ALU_control_lines(ALU_control_lines),
        .ALU_result(Write_Data),
        .zero(zero)
    );
    
endmodule