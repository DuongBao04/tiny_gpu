`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 10:32:58 AM
// Design Name: 
// Module Name: pc
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
module pc(
    input wire clk, reset, enable,
    input [2:0] core_state,
    input [7:0] current_pc,
    
    output reg [7:0] next_pc
    );
    
    always @(posedge clk) begin
        if (reset) begin
            next_pc <= 8'b0;
        end else if (enable) begin
            if (core_state == `CORE_EXECUTE) begin
                next_pc <= current_pc + 1;
            end
        end
    end
endmodule
