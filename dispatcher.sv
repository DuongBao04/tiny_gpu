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
    input clk, reset, start,
    
    input [7:0] thread_count,
    
    // Core's state management
    input [NUM_CORES-1:0] core_done, // each bit represent for a core
    output reg [NUM_CORES-1:0] core_start,
    output reg [NUM_CORES-1:0] core_reset,
    output reg [7:0] core_block_id [NUM_CORES-1:0], // ID of block being executed by core[i]
    output reg [$clog2(THREADS_PER_BLOCK):0] core_thread_count [NUM_CORES-1:0], // Number of threads in a block that are being executed by core[i]
    
    output reg done
    );
    // Calculate the total number of blocks based on total threads & threads per block
    wire [7:0] total_blocks;
    assign total_blocks = (thread_count + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    
    // Block tracking
    reg [7:0] blocks_dispatched;
    reg [7:0] blocks_done;
    reg start_execution;    // start_flag
    
    always@(posedge clk) begin
        if (reset) begin
            done <= 1'b0;
            blocks_dispatched <= 8'b0;
            blocks_done <= 8'b0;
            start_execution <= 1'b0;
            
            for (int i = 0; i < NUM_CORES; i++) begin
                core_start[i] <= 1'b0;
                core_reset[i] <= 1'b1;
                core_block_id[i] <= 1'b0;
            end
        
        end else if (start) begin
            if (!start_execution) begin
                start_execution <= 1'b1;
                for (int i = 0; i < NUM_CORES; i++) begin
                    core_reset[i] <= 1'b1;
                end
            end
            
            if (blocks_done == total_blocks) begin
                done <= 1'b0;
            end
            
            for (int i =0;i < NUM_CORES; i++) begin
                if (core_reset[i]) begin
                    core_reset[i] <= 1'b0;
                    
                    if (blocks_dispatched < total_blocks) begin
                        core_start[i] <= 1'b1;
                        core_block_id[i] <= blocks_dispatched;
                        core_thread_count[i] <= (blocks_dispatched == total_blocks - 1) 
                                                ? thread_count - (blocks_dispatched * THREADS_PER_BLOCK)
                                                : THREADS_PER_BLOCK;
                                                
                        blocks_dispatched = blocks_dispatched + 8'b1;
                    end
                end
            end
            
            for (int i = 0;i < NUM_CORES; i++) begin
                if (core_start[i] && core_done[i]) begin
                    core_reset[i] <= 1'b1;
                    core_start[i] <= 1'b0;
                    blocks_done = blocks_done + 1;
                end            
            end
            
        end
    end     
endmodule
