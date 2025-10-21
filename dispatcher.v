`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2025 09:41:16 PM
// Design Name: 
// Module Name: dispatcher
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


module dispatcher #(
    parameter NUM_CORES = 2,
    parameter THREADS_PER_BLOCK = 4
)(
    input wire clk,
    input wire reset,
    input wire start,
    
    input wire [7:0] thread_count,
    
    // Core's state management
    input wire [NUM_CORES-1:0] core_done,
    output reg [NUM_CORES-1:0] core_start,
    output reg [NUM_CORES-1:0] core_reset,
    output reg [7:0] core_block_id [NUM_CORES-1:0],
    
    output reg done
    );
    
    
endmodule
