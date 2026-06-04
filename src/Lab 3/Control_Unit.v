`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.02.2026 17:00:34
// Design Name: 
// Module Name: Control_Unit
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
module Control_Unit(
    input [31:0] Instruction_Code,
    input clk,
    input reset,
    output reg [4:0] Read_Reg_Num_1,
    output reg [4:0] Read_Reg_Num_2,
    output [4:0] Write_Reg_Num,
    output reg RegWrite,
    output reg [3:0] ALU_control_lines,
    output reg [1:0] ALUsrc
    );
    
assign Write_Reg_Num = Instruction_Code[25:21];
    
always @(*)
begin
    ALU_control_lines = 4'b0000;   // safe default
    Read_Reg_Num_1 = 5'b00000;
    Read_Reg_Num_2 = 5'b00000;
    RegWrite = 1'b0;
    ALUsrc = 2'b00;
    
    case (Instruction_Code[31:26])
        6'b111111: begin // I-type
            ALUsrc = 2'b10;
            ALU_control_lines = 4'b1111;
            RegWrite = 1'b1;
        end
        
        6'b000000: begin // R-type 
        RegWrite = 1'b1;
        Read_Reg_Num_1 = Instruction_Code[20:16];
        Read_Reg_Num_2 = Instruction_Code[15:11];
        ALUsrc = 2'b00;
        case (Instruction_Code[5:0])
            6'b100000: ALU_control_lines = 4'b0010;  // bitwise ADD
            6'b100010: ALU_control_lines = 4'b0100;  // bitwise SUB
            6'b100100: ALU_control_lines = 4'b0000;  // bitwise AND
            6'b100101: ALU_control_lines = 4'b0001;  // bitwise OR
            
            6'b000000: begin                         // bitwise SLL
                ALU_control_lines = 4'b1001;
                ALUsrc = 2'b01;
            end
            6'b000010: begin                         // bitwise SRL
                ALU_control_lines = 4'b1010;
                ALUsrc = 2'b01;
            end
            
            default:   ALU_control_lines = 4'bxxxx;
        endcase
        end
        default:   ALU_control_lines = 4'bxxxx;
    endcase 
end

endmodule