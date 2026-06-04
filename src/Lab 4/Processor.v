`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 21:53:54
// Design Name: 
// Module Name: Processor
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
module Processor(
    input clk,
    input reset
    );
    
    wire [7:0] Instruction_Code;
    wire [3:0] Read_Reg_Num;
    wire [3:0] Write_Reg_Num;
    wire [7:0] Read_Data;
    wire [7:0] Write_Data;
    wire [3:0] Reg;
    
    // Instantiate Instruction Fetch
    Instruction_Fetch IF2 (
        .clk(clk),
        .reset(reset),
        .Instruction_Code(Instruction_Code)
    );
    
    // Instantiate IF/ID Register
    IF_ID_Reg IF_ID1 (
        .Instruction_Code(Instruction_Code),
        .Read_Reg_Num(Read_Reg_Num),
        .Reg(Reg),
        .clk(clk)
    );
    
    // Instantiate Register File
    Register_File RF2 (
        .Read_Reg_Num(Read_Reg_Num),
        .Write_Reg_Num(Write_Reg_Num),
        .Write_Data(Write_Data),
        .Read_Data(Read_Data),
        .reset(reset)
    );
    
    // Instantiate ID/WB Register
    ID_WB_Reg ID_WB1 (
        .Read_Data(Read_Data),
        .Reg(Reg),
        .Write_Reg_Num(Write_Reg_Num),
        .Write_Data(Write_Data),
        .clk(clk)
    );
    
endmodule