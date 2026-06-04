`timescale 1ns / 1ps

module Instruction_Memory (
    input [31:0] PC,
    input reset,
    output [31:0] Instruction
);
    reg [7:0] IMem [63:0];
    assign Instruction = {IMem[PC], IMem[PC+1], IMem[PC+2], IMem[PC+3]};

    always @(negedge reset) begin
        if (reset == 0) begin
            {IMem[0],IMem[1],IMem[2],IMem[3]}   = 32'h2041000A; // addi R1, R2, 10
            {IMem[4],IMem[5],IMem[6],IMem[7]}   = 32'h20640005; // addi R4, R3, 5
            {IMem[8],IMem[9],IMem[10],IMem[11]} = 32'h00E60820; // add R7, R6, R1
            {IMem[12],IMem[13],IMem[14],IMem[15]} = 32'h01072024; // and R8, R7, R4
            {IMem[16],IMem[17],IMem[18],IMem[19]} = 32'hAC680004; // sw R8, 4(R3)
            {IMem[20],IMem[21],IMem[22],IMem[23]} = 32'h8C690004; // lw R9, 4(R3)
            {IMem[24],IMem[25],IMem[26],IMem[27]} = 32'h01490820; // add R10, R9, R1
            {IMem[28],IMem[29],IMem[30],IMem[31]} = 32'h0800000C; // j T (Address 48)
            {IMem[48],IMem[49],IMem[50],IMem[51]} = 32'h018A4024; // T: and R12, R10, R8
        end
    end
endmodule

module Instruction_Fetch (
    input clk, reset, PCSrc, Stall,
    input [31:0] Target_Address,
    output [31:0] Instruction
);
    reg [31:0] PC;
    Instruction_Memory IM1 (.PC(PC), .reset(reset), .Instruction(Instruction));

    always @(posedge clk or negedge reset) begin
        if (reset == 0) PC <= 0;
        else if (PCSrc) PC <= Target_Address; 
        else if (Stall) PC <= PC;
        else PC <= PC + 4;
    end
endmodule

module IF_ID_Reg(
    input [31:0] Instruction,
    input clk, reset, Stall,
    output reg [31:0] Instruction_Code
);
    always @(posedge clk or negedge reset) begin
        if (reset == 0) Instruction_Code <= 0;
        else if (Stall) Instruction_Code <= Instruction_Code;
        else Instruction_Code <= Instruction;
    end
endmodule

module Instruction_Decode(
    input [31:0] Instruction_Code,
    input reset, Stall,
    output reg [4:0] RS, RT, RD,
    output reg RegWrite, ALUsrc, MemWrite, MemToReg, PCSrc, DestSrc,
    output reg [3:0] ALU_control_lines,
    output reg [25:0] Jump_Offset,
    output reg [15:0] Const
);
    always @(*) begin
        {RS, RT, RD, RegWrite, ALUsrc, MemWrite, MemToReg, PCSrc, DestSrc, ALU_control_lines, Jump_Offset, Const} = 0;
        if (!Stall) begin
            case (Instruction_Code[31:26])
                6'b001000: begin // ADDI
                    RS = Instruction_Code[25:21]; RT = Instruction_Code[20:16];
                    Const = Instruction_Code[15:0]; RegWrite = 1; ALUsrc = 1; DestSrc = 1; ALU_control_lines = 4'b0010;
                end
                6'b100011: begin // LW
                    RS = Instruction_Code[25:21]; RT = Instruction_Code[20:16];
                    Const = Instruction_Code[15:0]; RegWrite = 1; ALUsrc = 1; MemToReg = 1; DestSrc = 1; ALU_control_lines = 4'b0010;
                end
                6'b101011: begin // SW
                    RS = Instruction_Code[25:21]; RT = Instruction_Code[20:16];
                    Const = Instruction_Code[15:0]; MemWrite = 1; ALUsrc = 1; ALU_control_lines = 4'b0010;
                end
                6'b000000: begin // R-Type
                    RS = Instruction_Code[25:21]; RT = Instruction_Code[20:16]; RD = Instruction_Code[15:11];
                    RegWrite = 1; case(Instruction_Code[5:0]) 6'b100000: ALU_control_lines = 4'b0010; 6'b100100: ALU_control_lines = 4'b0000; endcase
                end
                6'b000010: begin // Jump
                    PCSrc = 1; Jump_Offset = Instruction_Code[25:0];
                end
            endcase
        end
    end
endmodule

module ID_RF_Reg (
    input clk, reset, RegWrite_in, MemWrite_in, MemToReg_in, ALUsrc_in, DestSrc_in,
    input [3:0] ALU_control_in,
    input [4:0] RS_in, RT_in, RD_in,
    input [15:0] Const_in,
    output reg RegWrite_out, MemWrite_out, MemToReg_out, ALUsrc_out, DestSrc_out,
    output reg [3:0] ALU_control_out,
    output reg [4:0] RS_out, RT_out, RD_out,
    output reg [15:0] Const_out
);
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
             RegWrite_out <= 0; MemWrite_out <= 0; MemToReg_out <= 0;
             ALUsrc_out <= 0; DestSrc_out <= 0; ALU_control_out <= 0;
             RS_out <= 0; RT_out <= 0; RD_out <= 0; Const_out <= 0;
        end else begin
            RegWrite_out <= RegWrite_in; MemWrite_out <= MemWrite_in; MemToReg_out <= MemToReg_in;
            ALUsrc_out <= ALUsrc_in; DestSrc_out <= DestSrc_in; ALU_control_out <= ALU_control_in;
            RS_out <= RS_in; RT_out <= RT_in; RD_out <= RD_in; Const_out <= Const_in;
        end
    end
endmodule

module Register_File (
    input [4:0] RS, RT, Write_Reg_Num,
    input [31:0] Write_Data,
    input RegWrite, clk, reset,
    output reg [31:0] RS_Data, RT_Data
);
    reg [31:0] RegMemory [31:0];
    integer i;

    always @(negedge clk) begin
        RS_Data <= RegMemory[RS];
        RT_Data <= RegMemory[RT];
    end
    always @(posedge clk) if (RegWrite && Write_Reg_Num != 0) RegMemory[Write_Reg_Num] <= Write_Data;
    always @(negedge reset) begin
        for (i=0; i<32; i=i+1) RegMemory[i] <= 0;
    end
endmodule

module RF_EX_Reg (
    input clk, reset, RegWrite_in, MemWrite_in, MemToReg_in,
    input [31:0] A_in, B_in, RT_Data_in,
    input [4:0] Write_Reg_in, RS_in, RT_in,
    input [3:0] ALU_control_in,
    output reg [31:0] A_out, B_out, RT_Data_out,
    output reg [4:0] Write_Reg_out, RS_out, RT_out,
    output reg RegWrite_out, MemWrite_out, MemToReg_out,
    output reg [3:0] ALU_control_out
);
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            A_out <= 0; B_out <= 0; RT_Data_out <= 0;
            Write_Reg_out <= 0; RS_out <= 0; RT_out <= 0;
            RegWrite_out <= 0; MemWrite_out <= 0; MemToReg_out <= 0; ALU_control_out <= 0;
        end else begin
            A_out <= A_in; B_out <= B_in; RT_Data_out <= RT_Data_in;
            Write_Reg_out <= Write_Reg_in; RS_out <= RS_in; RT_out <= RT_in;
            RegWrite_out <= RegWrite_in; MemWrite_out <= MemWrite_in;
            MemToReg_out <= MemToReg_in; ALU_control_out <= ALU_control_in;
        end
    end
endmodule

module ALU (
    input [31:0] A, B,
    input [3:0] ALU_control_lines,
    output zero,
    output reg [31:0] ALU_result
);
    always @(*) begin
        case (ALU_control_lines)
            4'b0010: ALU_result = A + B;
            4'b0000: ALU_result = A & B;
            default: ALU_result = 0;
        endcase
    end
    assign zero = (ALU_result == 0);
endmodule

module EX_MEM_Reg (
    input clk, reset, MemWrite_in, RegWrite_in, MemToReg_in,
    input [31:0] ALU_result_in, RT_Data_in,
    input [4:0] Write_Reg_in, RS_in, RT_in,
    output reg [31:0] ALU_result_out, RT_Data_out,
    output reg [4:0] Write_Reg_out, RS_out, RT_out,
    output reg MemWrite_out, RegWrite_out, MemToReg_out
);
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            ALU_result_out <= 0; RT_Data_out <= 0; Write_Reg_out <= 0;
            RS_out <= 0; RT_out <= 0; MemWrite_out <= 0; RegWrite_out <= 0; MemToReg_out <= 0;
        end else begin
            ALU_result_out <= ALU_result_in; RT_Data_out <= RT_Data_in;
            Write_Reg_out <= Write_Reg_in; RS_out <= RS_in; RT_out <= RT_in;
            MemWrite_out <= MemWrite_in; RegWrite_out <= RegWrite_in; MemToReg_out <= MemToReg_in;
        end
    end
endmodule

module Data_Memory (
    input clk, reset, MemWrite,
    input [31:0] MemAddress, Write_Data,
    output [31:0] Mem_Data
);
    reg [7:0] DMem [127:0];
    integer i;

    assign Mem_Data = {DMem[MemAddress], DMem[MemAddress+1], DMem[MemAddress+2], DMem[MemAddress+3]};
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            for (i=0; i<128; i=i+1) DMem[i] <= 0;
            DMem[10] <= 8'd96;
        end else if (MemWrite) begin
            {DMem[MemAddress], DMem[MemAddress+1], DMem[MemAddress+2], DMem[MemAddress+3]} <= Write_Data;
        end
    end
endmodule

module MEM_WB_Reg (
    input clk, reset, RegWrite_in, MemToReg_in,
    input [31:0] Mem_Data_in, ALU_result_in,
    input [4:0] Write_Reg_in, RS_in, RT_in,
    output reg [31:0] Mem_Data_out, ALU_result_out,
    output reg [4:0] Write_Reg_out, RS_out, RT_out,
    output reg RegWrite_out, MemToReg_out
);
    always @(posedge clk or negedge reset) begin
        if (reset == 0) begin
            Mem_Data_out <= 0; ALU_result_out <= 0; Write_Reg_out <= 0;
            RS_out <= 0; RT_out <= 0; RegWrite_out <= 0; MemToReg_out <= 0;
        end else begin
            Mem_Data_out <= Mem_Data_in; ALU_result_out <= ALU_result_in;
            Write_Reg_out <= Write_Reg_in; RS_out <= RS_in; RT_out <= RT_in;
            RegWrite_out <= RegWrite_in; MemToReg_out <= MemToReg_in;
        end
    end
endmodule

// ----------------------------------------------------------------------------
// Forwarding Unit
// Compares the destination register resolved in ID_RF stage (Write_Reg_ID_RF,
// i.e. Rd or Rt chosen by DestSrc) against RS and RT of the instruction
// currently in IF_ID (i.e. the next instruction being decoded).
// ----------------------------------------------------------------------------
module Forwarding_Unit (
    // Source operands from IF_ID register (next instruction being decoded)
    input [4:0] RS_IF_ID, RT_IF_ID,
    // Destination register resolved in ID_RF stage (Rd or Rt per DestSrc)
    input [4:0] Write_Reg_ID_RF,
    // Destination and write-enable from EX/MEM stage (for MEM-stage forwarding)
    input [4:0] Write_Reg_EX_MEM,
    input RegWrite_ID_RF, RegWrite_EX_MEM,
    output reg [1:0] A_Forward, B_Forward
);
    always @(*) begin
        A_Forward = 2'b00;
        B_Forward = 2'b00;

        // EX forwarding: destination resolved in ID_RF vs operands in IF_ID
        // 2'b10 => forward from ID_RF result (one stage ahead)
        if (RegWrite_ID_RF && Write_Reg_ID_RF != 0 && Write_Reg_ID_RF == RS_IF_ID)
            A_Forward = 2'b10;
        else if (RegWrite_EX_MEM && Write_Reg_EX_MEM != 0 && Write_Reg_EX_MEM == RS_IF_ID)
            A_Forward = 2'b01;

        if (RegWrite_ID_RF && Write_Reg_ID_RF != 0 && Write_Reg_ID_RF == RT_IF_ID)
            B_Forward = 2'b10;
        else if (RegWrite_EX_MEM && Write_Reg_EX_MEM != 0 && Write_Reg_EX_MEM == RT_IF_ID)
            B_Forward = 2'b01;
    end
endmodule

module Stall_Unit (
    input [4:0] RS_ID_RF, RT_ID_RF, Write_Reg_RF_EX,
    input MemToReg_RF_EX,
    output reg Stall
);
    always @(*) begin
        Stall = 0;
        if (MemToReg_RF_EX && (Write_Reg_RF_EX == RS_ID_RF || Write_Reg_RF_EX == RT_ID_RF)) Stall = 1;
    end
endmodule