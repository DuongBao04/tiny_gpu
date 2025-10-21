`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 10:27:07 AM
// Design Name: 
// Module Name: scheduler
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
module scheduler (
    input  clk, reset, start,
    input [2:0] fetcher_state,
    input [1:0] lsu_state [3:0],
    
    input  ProgramEnd,
    
    input wire [7:0] next_pc [3:0],
    output reg [7:0] current_pc,
    output reg [2:0] core_state,
    output reg done
    );
       
    integer any_lsu_waiting;
    
    always@(posedge clk) begin
        if (reset) begin
            current_pc <= 8'b0;
            core_state <= `CORE_IDLE;
            done <= 1'b0;
        end else begin
            case (core_state)
                `CORE_IDLE: begin
                    if (start) begin
                        core_state <= `CORE_FETCH;
                    end
                end
                
                `CORE_FETCH: begin
                    if (fetcher_state == `FETCHER_FETCHED) begin
                        core_state <= `CORE_DECODE;
                    end
                end
                
                `CORE_DECODE: begin
                    core_state <= `CORE_REQUEST;
                end
                
                `CORE_REQUEST: begin
                    core_state <= `CORE_WAIT;
                end
                
                `CORE_WAIT: begin
                    any_lsu_waiting = 0;
                    for (int i =0;i<4; i++) begin
                        if (lsu_state[i] == `LSU_REQUESTING || lsu_state[i] == `LSU_WAITING) begin
                            any_lsu_waiting = 1'b1;
                            break;
                        end
                    end
                    
                    if (!any_lsu_waiting) begin 
                        core_state <= `CORE_EXECUTE;
                    end
                end
                
                `CORE_EXECUTE: begin
                    core_state <= `CORE_WRITEBACK;
                end
                
                `CORE_WRITEBACK: begin
                    // if met RETURN instruction
                    if (ProgramEnd) begin
                        done <= 1'b1;
                        core_state <= `CORE_DONE;
                    end else begin
                        current_pc <= next_pc[3];
                        core_state <= `CORE_FETCH;
                    end
                end
                
                `CORE_DONE: begin end    
            endcase        
        end
    end
endmodule
