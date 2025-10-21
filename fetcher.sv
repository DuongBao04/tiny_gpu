`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 04:02:22 PM
// Design Name: 
// Module Name: fetcher
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Fetch instructin ffro Program Memory based on Program Counter (PC) of core, each core
// will havve its own fetcher
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "defines.vh"
module fetcher (
    input clk, reset,
    
    // Execution State
    input wire [2:0] core_state,
    input wire [7:0] current_pc,
    
    // Program Memory
    output reg mem_read_request,
    output reg [7:0] mem_read_address,
    input  mem_read_ready,
    input [7:0] mem_read_data,
    
    // Fetcher output
    output reg [2:0] fetcher_state,
    output reg [15:0] instruction
    );
    
    always@(posedge clk) begin
        if (reset) begin
            fetcher_state <= `FETCHER_IDLE;
            mem_read_request <= 0;
            mem_read_address <= 0;
            instruction <= {16{1'b0}};
        end else begin
            case (fetcher_state)
                `FETCHER_IDLE: begin
                    if (core_state == `CORE_FETCH) begin
                        fetcher_state <= `FETCHER_FETCHING;
                        mem_read_request <= 1'b1;
                        mem_read_address <= current_pc;
                    end
                end
                
                `FETCHER_FETCHING: begin
                    if (mem_read_ready) begin
                        fetcher_state <= `FETCHER_FETCHED;
                        instruction <= mem_read_data;
                        mem_read_request <= 1'b0;
                    end
                end
                
                `FETCHER_FETCHED: begin
                    if (core_state == `CORE_DECODE) begin
                        fetcher_state <= `FETCHER_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
