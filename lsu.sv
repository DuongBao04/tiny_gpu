`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 11:39:22 AM
// Design Name: 
// Module Name: lsu
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

module lsu(
    input clk, reset, enable, 

    // State
    input wire [2:0] core_state,

    // Memory Control Sgiansl
    input wire MemRead,
    input wire MemWrite,

    // Registers
    input wire [7:0] rs,
    input wire [7:0] rt,

    // Data Memory
    output reg mem_read_request,
    output reg [7:0] mem_read_address,
    input wire mem_read_ready,
    input wire [7:0] mem_read_data,
    output reg mem_write_request,
    output reg [7:0] mem_write_address,
    output reg [7:0] mem_write_data,
    input wire mem_write_ready,

    // LSU Outputs
    output reg [1:0] lsu_state,
    output reg [7:0] lsu_out
    );
    
    
    always@(posedge clk) begin
        if (reset) begin
        
        end else if (enable) begin
            if (MemRead) begin
                case (lsu_state)
                    `LSU_IDLE: begin
                        if (core_state == `CORE_REQUEST) begin
                            lsu_state <= `LSU_REQUESTING;
                        end
                    end
                    
                    `LSU_REQUESTING: begin
                        mem_read_request <= 1;
                        mem_read_address <= rs;
                        lsu_state <= `LSU_WAITING;
                    end
                    
                    `LSU_WAITING: begin
                        if (mem_read_ready) begin
                            mem_read_request <= 1;
                            lsu_out <= mem_read_data;
                            lsu_state <= `LSU_DONE;
                        end
                    end
                    
                    `LSU_DONE: begin
                        if (core_state == `CORE_WRITEBACK) begin
                            lsu_state <= `LSU_IDLE;
                        end
                    end
                endcase
            end
            
            if (MemWrite) begin
                case (lsu_state)
                    `LSU_IDLE: begin
                        if (core_state == `CORE_REQUEST) begin
                            lsu_state <= `LSU_REQUESTING;
                        end
                    end
                    `LSU_REQUESTING: begin 
                        mem_write_request <= 1;
                        mem_write_address <= rs;
                        mem_write_data <= rt;
                        lsu_state <= `LSU_WAITING;
                    end
                    `LSU_WAITING: begin
                        if (mem_write_ready) begin
                            mem_write_request <= 0;
                            lsu_state <= `LSU_DONE;
                        end
                    end    
                    `LSU_DONE: begin
                        if (core_state == `CORE_WRITEBACK) begin
                            lsu_state <= `LSU_IDLE;
                        end
                    end
                endcase            
            end
        end
    end
endmodule
