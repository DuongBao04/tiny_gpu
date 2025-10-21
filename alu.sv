`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 11:29:51 PM
// Design Name: 
// Module Name: alu
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
module alu(
    input clk, reset, enable,
    input [1:0] ALUControl,
    
    input [2:0] core_state,
    input [7:0] rs,
    input [7:0] rt,
    output reg [7:0] alu_out
    );
     
    always@(posedge clk) begin
        if (reset) begin
            alu_out <= 8'b0;
        end else if (enable && core_state == `CORE_EXECUTE) begin
            case (ALUControl) 
                `ALU_ADD: begin 
                    alu_out <= rs + rt;
                end
                `ALU_SUB: begin 
                    alu_out <= rs - rt;
                end
                `ALU_MUL: begin 
                    alu_out <= rs * rt;
                end
                `ALU_DIV: begin 
                    alu_out <= rs / rt;
                end
            endcase
        end
    end
    
    
endmodule
