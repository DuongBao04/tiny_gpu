`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 09:09:37 AM
// Design Name: 
// Module Name: register
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
module register #(
    parameter THREAD_ID = 0
)(
    input wire clk, reset, enable,
    
    input wire [7:0] block_id,
    input wire [2:0] core_state,
    
    input wire [3:0] rd_address,
    input wire [3:0] rs_address,
    input wire [3:0] rt_address,
    
    input wire [7:0] WriteData,
    input wire RegWrite,
    
    
    output reg [7:0] rs,
    output reg [7:0] rt
    );
    
    reg [7:0] register [15:0];
    
    always@(posedge clk) begin
        if (reset) begin
            rs <= 0;
            rt <= 0;
            
            // free register
            for (int i = 0;i<13;i++) begin
                register[i] <= 8'b0;
            end
            
            // read-only register
            register[13] <= 8'b0;              // %blockIdx
            register[14] <= 4;                 // %blockDim
            register[15] <= THREAD_ID;         // %threadIdx
        end
        else if (enable) begin
            register[13] <= block_id;
            
            if (core_state == `CORE_REQUEST) begin
                rs <= register[rs_address];
                rt <= register[rt_address];
            end
            
            if (core_state == `CORE_WRITEBACK) begin
                if (RegWrite && rd_address < 13) begin
                    register[rd_address] <= WriteData;
                end
            end
        end
        
        
    end
    
endmodule
