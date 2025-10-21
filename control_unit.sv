`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 04:45:34 PM
// Design Name: 
// Module Name: control_unit
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

`include "defines.vh"
module control_unit(
    input clk, reset,
    input [3:0] opcode,
    input [2:0] core_state,
    
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg [1:0] MemToReg,
    output reg [1:0] ALUControl,
    output reg ProgramEnd
    );
    always@(posedge clk) begin
        if (reset) begin
            RegWrite <= 0;
            ALUSrc <= 0;
            MemRead <= 0;
            MemWrite <= 0;
            MemToReg <= 0;
            ALUControl <= 0;
        end else begin
            if (core_state == `CORE_DECODE) begin
                case(opcode)
                    `OPCODE_ADD: begin
                        RegWrite <= 1;
                        MemToReg <= 2'b0;
                        ALUControl <= `ALU_ADD;
                    end
                    
                    `OPCODE_SUB: begin
                        RegWrite <= 1;
                        MemToReg <= 2'b0;
                        ALUControl <= `ALU_SUB;
                    end
                    
                    `OPCODE_MUL: begin
                        RegWrite <= 1;
                        MemToReg <= 2'b0;
                        ALUControl <= `ALU_MUL;
                    end
                    
                    `OPCODE_DIV: begin
                        RegWrite <= 1;
                        MemToReg <= 2'b0;
                        ALUControl <= `ALU_DIV;
                    end
                    
                    `OPCODE_LOAD: begin
                        RegWrite <= 1;
                        MemToReg <= 2'b01;
                        MemRead  <= 1;
                    end
                    
                    `OPCODE_STORE: begin
                        MemWrite <= 1;
                    end
                    
                    `OPCODE_CONST: begin
                        MemToReg <= 2'b10;
                        RegWrite <= 1;
                    end
                    
                    `OPCODE_RETURN: begin
                        ProgramEnd <= 1;
                    end
                endcase
            end
        end
    end
    
endmodule
