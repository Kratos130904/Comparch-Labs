`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2026 18:50:24
// Design Name: 
// Module Name: ALU
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
module ALU(
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_control_lines,
    output wire zero,
    output reg [31:0] ALU_result
    );

    always @(*) begin
        case (ALU_control_lines)
            4'b0000: ALU_result = A & B;          // Bitwise AND
            4'b0001: ALU_result = A | B;          // Bitwise OR
            4'b0010: ALU_result = A + B;          // Add
            4'b0100: ALU_result = A - B;          // Subtract
            4'b1000: ALU_result = (A < B) ? 32'd1 : 32'd0; // Set on less than
            //3'b100: out = a * b;       // Multiplication
            //3'b101: begin              // Division
            //    if (b != 0) out = a / b;
            //    else out = 0;          // Handle division by zero
            //end
            //3'b110: begin              // Modulo (Remainder)
            //    if (b != 0) out = a % b;
            //    else out = 0;
            //end
            default: ALU_result = 32'd0;
        endcase
    end

    // Zero flag logic
    assign zero = (ALU_result == 32'd0);

endmodule