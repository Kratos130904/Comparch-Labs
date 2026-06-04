`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.04.2026 15:32:31
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
module Processor (
    input clk,
    input reset
);

// --- Wire Definitions for Stage Interconnections ---
    // IF Stage
    wire [31:0] IF_Instruction, PC_plus_4, Target_Address;
    
    // ID Stage
    wire [31:0] ID_Instruction;
    wire [4:0] ID_RS, ID_RT, ID_RD;
    wire [3:0] ID_ALU_Control;
    wire [25:0] ID_Jump_Offset;
    wire [15:0] ID_Const;
    wire ID_RegWrite, ID_ALUsrc, ID_MemWrite, ID_MemToReg, ID_PCSrc, ID_DestSrc;

    // RR Stage
    wire [31:0] RR_RS_Data, RR_RT_Data, RR_SignExtended;
    wire [31:0] RR_B_Mux_Out;
    wire [4:0] RR_RS, RR_RT, RR_RD, RR_Write_Reg_Out;
    wire [3:0] RR_ALU_Control;
    wire RR_RegWrite, RR_MemWrite, RR_MemToReg, RR_ALUsrc, RR_DestSrc;

    // EX Stage
    wire [31:0] EX_A, EX_B, EX_RT_Data, EX_ALU_Result;
    wire [31:0] EX_Forward_A_Mux, EX_Forward_B_Mux;
    wire [4:0] EX_Write_Reg, EX_RS, EX_RT;
    wire [3:0] EX_ALU_Control;
    wire EX_RegWrite, EX_MemWrite, EX_MemToReg, EX_Zero;
    wire [1:0] ForwardA, ForwardB;
    wire EX_ALUsrc;

    // MEM Stage
    wire [31:0] MEM_ALU_Result, MEM_RT_Data, MEM_Data_Out;
    wire [4:0] MEM_Write_Reg;
    wire MEM_RegWrite, MEM_MemWrite, MEM_MemToReg;

    // WB Stage
    wire [31:0] WB_Mem_Data, WB_ALU_Result, WB_Final_Write_Data;
    wire [4:0] WB_Write_Reg;
    wire WB_RegWrite, WB_MemToReg;

    // Hazard & Flush
    wire Stall, Flush;
    
    wire [15:0] ID_Const_Out; // To catch the output from the ID_RR register
    wire [31:0] SignExtendedImmediate;   

    // Source operands of the instruction currently in IF/ID
    // (the instruction one stage behind ID_RF, i.e. the next instruction to be decoded)
    wire [4:0] RS_IF_ID = ID_Instruction[25:21];
    wire [4:0] RT_IF_ID = ID_Instruction[20:16];

    // -------------------------------------------------------------------------
    // 1. FETCH STAGE (IF)
    // -------------------------------------------------------------------------
    Instruction_Fetch IF_Unit (
        .clk(clk), .reset(reset), .Stall(Stall), .PCSrc(ID_PCSrc),
        .Target_Address(Target_Address), .Instruction(IF_Instruction)
    );

    IF_ID_Reg IF_ID (
        .clk(clk), .reset(reset && !Flush), .Stall(Stall),
        .Instruction(IF_Instruction), .Instruction_Code(ID_Instruction)
    );

    // -------------------------------------------------------------------------
    // 2. DECODE STAGE (ID)
    // -------------------------------------------------------------------------
    Instruction_Decode ID_Unit (
        .Instruction_Code(ID_Instruction), .Stall(Stall), .reset(reset), .RS(ID_RS), .RT(ID_RT), 
        .RD(ID_RD), .RegWrite(ID_RegWrite), .ALU_control_lines(ID_ALU_Control),
        .ALUsrc(ID_ALUsrc), .MemWrite(ID_MemWrite), .MemToReg(ID_MemToReg),
        .PCSrc(ID_PCSrc), .Jump_Offset(ID_Jump_Offset), .DestSrc(ID_DestSrc), .Const(ID_Const)
    );

    // Jump logic: Target = {PC[31:28], Offset << 2}
    assign Target_Address = {4'b0000, ID_Jump_Offset, 2'b00}; 
    
    // --- Control Signal Bubble Mux ---
    wire Stall_RegWrite = (Stall) ? 1'b0 : ID_RegWrite;
    wire Stall_MemWrite = (Stall) ? 1'b0 : ID_MemWrite;
    wire Stall_MemToReg = (Stall) ? 1'b0 : ID_MemToReg;
    wire Stall_ALUsrc   = (Stall) ? 1'b0 : ID_ALUsrc;
    
    ID_RF_Reg ID_RR (
        .clk(clk), .reset(reset), .RegWrite_in(Stall_RegWrite), .MemWrite_in(Stall_MemWrite),
        .MemToReg_in(Stall_MemToReg), .ALUsrc_in(Stall_ALUsrc), .ALU_control_in(ID_ALU_Control),
        .RS_in(ID_RS), .RT_in(ID_RT), .RD_in(ID_RD), .Const_in(ID_Const), .DestSrc_in(ID_DestSrc),
        .RegWrite_out(RR_RegWrite), .MemWrite_out(RR_MemWrite), .MemToReg_out(RR_MemToReg),
        .ALUsrc_out(RR_ALUsrc), .ALU_control_out(RR_ALU_Control), .RS_out(RR_RS), 
        .RT_out(RR_RT), .RD_out(RR_RD), .DestSrc_out(RR_DestSrc), .Const_out(ID_Const_Out)
    );

    // Destination register resolved in ID_RF stage: Rd (R-type) or Rt (I-type)
    // RR_Write_Reg_Out = (RR_DestSrc) ? RR_RT : RR_RD
    assign RR_Write_Reg_Out = (RR_DestSrc) ? RR_RT : RR_RD;

    // -------------------------------------------------------------------------
    // 3. REGISTER READ STAGE (RR)
    // -------------------------------------------------------------------------
    Register_File RF (
        .clk(clk), .reset(reset), .RS(RR_RS), .RT(RR_RT), 
        .Write_Reg_Num(WB_Write_Reg), .Write_Data(WB_Final_Write_Data),
        .RS_Data(RR_RS_Data), .RT_Data(RR_RT_Data), .RegWrite(WB_RegWrite)
    );

    assign RR_SignExtended = {{16{ID_Const_Out[15]}}, ID_Const_Out};
    assign RR_B_Mux_Out = (RR_ALUsrc) ? RR_SignExtended : RR_RT_Data;

    wire [31:0] RR_RT_Data_Forwarded;
    assign RR_RT_Data_Forwarded = 
        (MEM_RegWrite && MEM_Write_Reg != 0 && MEM_Write_Reg == RR_RT) ? MEM_ALU_Result :
        (WB_RegWrite  && WB_Write_Reg  != 0 && WB_Write_Reg  == RR_RT) ? WB_Final_Write_Data :
        RR_RT_Data;
    
    RF_EX_Reg RR_EX (
        .clk(clk), .reset(reset), .A_in(RR_RS_Data), .B_in(RR_B_Mux_Out), .ALUsrc_in(RR_ALUsrc),
        .RT_Data_in(RR_RT_Data_Forwarded), .Write_Reg_in(RR_Write_Reg_Out), .RS_in(RR_RS), .RT_in(RR_RT),
        .RegWrite_in(RR_RegWrite), .MemWrite_in(RR_MemWrite), .MemToReg_in(RR_MemToReg), .ALU_control_in(RR_ALU_Control),
        .RS_out(EX_RS), .RT_out(EX_RT), .A_out(EX_A), .B_out(EX_B), .RT_Data_out(EX_RT_Data), .ALUsrc_out(EX_ALUsrc),
        .Write_Reg_out(EX_Write_Reg), .RegWrite_out(EX_RegWrite), .MemWrite_out(EX_MemWrite), 
        .MemToReg_out(EX_MemToReg), .ALU_control_out(EX_ALU_Control)
    );

    // -------------------------------------------------------------------------
    // 4. EXECUTE STAGE (EX)
    // -------------------------------------------------------------------------
    // Forwarding Unit:
    //   - Compares destination resolved in ID_RF (RR_Write_Reg_Out) against
    //     RS/RT of the instruction in IF_ID (RS_IF_ID, RT_IF_ID).
    //   - Also checks EX/MEM destination against IF_ID operands for the
    //     second forwarding path.
    Forwarding_Unit FU (
        .RS_IF_ID(EX_RS),
        .RT_IF_ID(EX_RT),
        .Write_Reg_ID_RF(MEM_Write_Reg),      // instr 1 cycle ahead of EX
        .RegWrite_ID_RF(MEM_RegWrite),
        .Write_Reg_EX_MEM(WB_Write_Reg),      // instr 2 cycles ahead of EX
        .RegWrite_EX_MEM(WB_RegWrite),
        .A_Forward(ForwardA),
        .B_Forward(ForwardB)
    );
    
    // 3x1 MUXes for Forwarding
    assign EX_Forward_A_Mux = (ForwardA == 2'b10) ? MEM_ALU_Result : 
                              (ForwardA == 2'b01) ? WB_Final_Write_Data : EX_A;
    assign EX_Forward_B_Mux = (EX_ALUsrc) ? EX_B :
                               (ForwardB == 2'b10) ? MEM_ALU_Result : 
                               (ForwardB == 2'b01) ? WB_Final_Write_Data : EX_B;

    ALU Main_ALU (
        .A(EX_Forward_A_Mux), .B(EX_Forward_B_Mux), 
        .ALU_control_lines(EX_ALU_Control), .zero(EX_Zero), .ALU_result(EX_ALU_Result)
    );
    
    // Dedicated forward select for SW store data (RT register, not ALU B)
    wire [1:0] ForwardRT_Store;
    assign ForwardRT_Store = (MEM_RegWrite && MEM_Write_Reg != 0 && MEM_Write_Reg == EX_RT) ? 2'b10 :
                             (WB_RegWrite  && WB_Write_Reg  != 0 && WB_Write_Reg  == EX_RT) ? 2'b01 :
                                                                                               2'b00;
    
    wire [31:0] EX_RT_Data_Forwarded;
    assign EX_RT_Data_Forwarded = (ForwardRT_Store == 2'b10) ? MEM_ALU_Result :
                                  (ForwardRT_Store == 2'b01) ? WB_Final_Write_Data : EX_RT_Data;
                              
    EX_MEM_Reg EX_MEM (
        .clk(clk), .reset(reset),  .ALU_result_in(EX_ALU_Result), .RT_Data_in(EX_RT_Data_Forwarded),
        .Write_Reg_in(EX_Write_Reg), .MemWrite_in(EX_MemWrite), .RegWrite_in(EX_RegWrite),
        .MemToReg_in(EX_MemToReg), .ALU_result_out(MEM_ALU_Result), .RT_Data_out(MEM_RT_Data),
        .Write_Reg_out(MEM_Write_Reg), .MemWrite_out(MEM_MemWrite), .RegWrite_out(MEM_RegWrite),
        .MemToReg_out(MEM_MemToReg)
    );

    // -------------------------------------------------------------------------
    // 5. MEMORY STAGE (MEM)
    // -------------------------------------------------------------------------
    Data_Memory DMEM (
        .clk(clk), .reset(reset), .MemWrite(MEM_MemWrite), 
        .MemAddress(MEM_ALU_Result), .Write_Data(MEM_RT_Data), .Mem_Data(MEM_Data_Out)
    );

    MEM_WB_Reg MEM_WB (
        .clk(clk), .reset(reset), .Mem_Data_in(MEM_Data_Out), .ALU_result_in(MEM_ALU_Result),
        .Write_Reg_in(MEM_Write_Reg), .RegWrite_in(MEM_RegWrite), .MemToReg_in(MEM_MemToReg),
        .Mem_Data_out(WB_Mem_Data), .ALU_result_out(WB_ALU_Result), .Write_Reg_out(WB_Write_Reg),
        .RegWrite_out(WB_RegWrite), .MemToReg_out(WB_MemToReg)
    );

    // -------------------------------------------------------------------------
    // 6. WRITE BACK STAGE (WB)
    // -------------------------------------------------------------------------
    assign WB_Final_Write_Data = (WB_MemToReg) ? WB_Mem_Data : WB_ALU_Result;

    // -------------------------------------------------------------------------
    // HAZARD & FLUSH UNIT
    // -------------------------------------------------------------------------
    Stall_Unit Hazard_Control (
        .RS_ID_RF(RR_RS), .RT_ID_RF(RR_RT),
        .Write_Reg_RF_EX(EX_Write_Reg),
        .MemToReg_RF_EX(EX_MemToReg),
        .Write_Reg_ID_RF(RR_Write_Reg_Out),
        .MemToReg_ID_RF(RR_MemToReg),
        .Stall(Stall)
    );
    
endmodule