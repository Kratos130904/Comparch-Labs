`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.02.2026 18:56:11
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

`timescale 1ns/1ps
module Processor(
    input clk,
    input reset,
    output zero
    );

    wire [31:0] Instruction_Code;
    wire [4:0] Read_Reg_Num_1;
    wire [4:0] Read_Reg_Num_2;
    wire [4:0] Write_Reg_Num;
    wire [31:0] Read_Data_1;
    wire [31:0] Read_Data_2;
    wire [31:0] ALU_result;
    wire [3:0] ALU_control_lines;
    wire [1:0] ALUsrc;
    wire RegWrite;
    reg [31:0]  ALU_B_input; // Register for Mux logic
    
    // Instantiate Instruction Fetch
    Instruction_Fetch IF1 (
        .clk(clk),
        .reset(reset),
        .Instruction_Code(Instruction_Code)
    );
    
    // Instantiate Control Unit
    Control_Unit ID1 (
        .Instruction_Code(Instruction_Code),
        .clk(clk),
        .reset(reset),
        .Read_Reg_Num_1(Read_Reg_Num_1),
        .Read_Reg_Num_2(Read_Reg_Num_2),
        .Write_Reg_Num(Write_Reg_Num),
        .RegWrite(RegWrite),
        .ALU_control_lines(ALU_control_lines),
        .ALUsrc(ALUsrc)
    );
    
    // Instantiate Register File
    Register_File RF1 (
        .Read_Reg_Num_1(Read_Reg_Num_1),
        .Read_Reg_Num_2(Read_Reg_Num_2),
        .Write_Reg_Num(Write_Reg_Num),
        .Write_Data(ALU_result),
        .Read_Data_1(Read_Data_1),
        .Read_Data_2(Read_Data_2),
        .RegWrite(RegWrite),
        .clk(clk),
        .reset(reset)
    );
    
    // ALU Input B Mux Logic
    wire [31:0] ext_const = {{11{Instruction_Code[20]}}, Instruction_Code[20:0]}; 
    // Sign-extend 21-bit constant 
    wire [31:0] ext_shamt = {27'b0, Instruction_Code[10:6]}; 
    // Zero-extend 5-bit shamt

    always @(*) begin
        case(ALUsrc)
            2'b00: ALU_B_input = Read_Data_2; // R-type Arith
            2'b01: ALU_B_input = ext_shamt;    // Shift amount
            2'b10: ALU_B_input = ext_const;    // Immediate
            default: ALU_B_input = 32'b0;
        endcase
    end    
    
    // Instantiate ALU 
    ALU A1 (
        .A(Read_Data_1),
        .B(ALU_B_input),
        .ALU_control_lines(ALU_control_lines),
        .zero(zero),
        .ALU_result(ALU_result)
    );
    
endmodule
