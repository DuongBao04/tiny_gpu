`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 03:20:30 PM
// Design Name: 
// Module Name: decoder
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
module decoder(
    input clk, reset,
    
    input wire [2:0] core_state,
    input wire [15:0] instruction,
    
    output reg [3:0] rd_address,
    output reg [3:0] rs_address,
    output reg [3:0] rt_address,
    output reg [7:0] immediate
    
    // control signal
    );
    
    always@(posedge clk) begin
        if (reset) begin
            
        end else begin
            if (core_state == `CORE_DECODE) begin
                rd_address <= instruction[11:8];
                rs_address <= instruction [7:4];
                rt_address <= instruction [3:0];
                immediate <=  instruction [7:0];
            end
        end
    end
    
endmodule
