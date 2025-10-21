`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 05:57:35 PM
// Design Name: 
// Module Name: core
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


module core (
    input clk, reset,
    
    // Kernel execution
    input start,
    input done,
    
    input [7:0] block_id,
    input [2:0] thread_count,
    
    // Instruction Memory
    output reg instruction_mem_read_request,
    output reg [7:0] instruction_mem_read_addr,
    input wire instruction_mem_read_ready,
    input wire [15:0] instruction_mem_read_data,
    
    // Data Memory
    output reg [3:0] data_mem_read_request,
    output reg [7:0] data_mem_read_address [3:0],
    input wire [3:0] data_mem_read_ready,
    input wire [7:0] data_mem_read_data [3:0],
    output reg [3:0] data_mem_write_request,
    output reg [7:0] data_mem_write_address [3:0],
    output reg [7:0] data_mem_write_data [3:0],
    input wire [3:0] data_mem_write_ready
    );
    // State
    wire [2:0] core_state;
    wire [2:0] fetcher_state;
    wire [15:0] instruction;
    
    // Intermediate Signal
    wire [7:0] current_pc;
    wire [7:0] next_pc [3:0];
    wire [1:0] lsu_state [3:0];
    wire [7:0] lsu_out [3:0];
    wire [7:0] rs [3:0];
    wire [7:0] rt [3:0];
    wire [7:0] alu_out [3:0];
    wire [7:0] WriteData [3:0];
    
    // Decoder signals
    wire [3:0] rd_address;
    wire [3:0] rs_address;
    wire [3:0] rt_address;
    wire [7:0] immediate;
    
    // Control Unit
    wire RegWrite, ALUSrc, MemRead, MemWrite, ProgramDone ;
    wire ALUControl;
    wire [1:0] MemToReg;

    fetcher fetcher_instance (
        .clk(clk),
        .reset(reset), 
        .core_state(core_state),
        .current_pc(current_pc),
        .mem_read_request(instruction_mem_read_request),
        .mem_read_address(instruction_mem_read_addr),
        .mem_read_ready(instruction_mem_read_ready),
        .mem_read_data(instruction_mem_read_data),
        .fetcher_state(fetcher_state),
        .instruction(instruction)
    );
    
    control_unit CU_instance (
        .clk(clk),
        .reset(reset),
        .opcode(instruction[15:12]),
        .core_state(core_state),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUControl(ALUControl),
        .ProgramEnd(ProgramEnd)
    );
    
    decoder decoder_instance (
        .clk(clk),
        .reset(reset),
        .core_state(core_state),
        .instruction(instruction),
        .rd_address(rd_address),
        .rt_address(rt_address),
        .rs_address(rs_address),
        .immediate(immediate)
    );
    
    scheduler scheduler_instance (
        .clk(clk),
        .reset(reset),
        .start(start),
        .fetcher_state(fetcher_state),
        .core_state(core_state),
        .lsu_state(lsu_state),
        .ProgramEnd(ProgramEnd),
        .current_pc(current_pc),
        .next_pc(next_pc),
        .done(done)
    );
    
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : threads
           //ALU 
           alu alu_instance (
            .clk(clk),
            .reset(reset),
            .enable(i < thread_count),
            .core_state(core_state),
            .ALUControl(ALUControl),
            .rs(rs[i]),
            .rt(rt[i]),
            .alu_out(alu_out[i])
           );
           
           lsu lsu_instance (
            .clk(clk),
            .reset(reset),
            .enable(i < thread_count),
            .core_state(core_state),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .mem_read_request(data_mem_read_request[i]),
            .mem_read_address(data_mem_read_address[i]),
            .mem_read_ready(data_mem_read_ready[i]),
            .mem_read_data(data_mem_read_data[i]),
            .mem_write_request(data_mem_read_request[i]),
            .mem_write_address(data_mem_write_address[i]),
            .mem_write_ready(data_mem_write_ready[i]),
            .mem_write_data(data_mem_write_data[i]),
            .rs(rs[i]),
            .rt(rt[i]),
            .lsu_state(lsu_state[i]),
            .lsu_out(lsu_out[i])
           );
           
           MUX mux_instance (
            .op1(alu_out[i]),
            .op2(lsu_out[i]),
            .op3(immediate),
            .sel(MemToReg),
            .out_data(WriteData[i])
           );
           
           register #(
             .THREAD_ID(i)
           ) register_instance (
            .clk(clk),
            .reset(reset),
            .enable(i < thread_count),
            .block_id(block_id),
            .core_state(core_state),
            .rd_address(rd_address),
            .rs_address(rs_address),
            .rt_address(rt_address),
            .WriteData(WriteData[i]),
            .RegWrite(RegWrite),
            .rs(rs[i]),
            .rt(rt[i])
           );
           
           pc pc_instance (
            .clk(clk),
            .reset(reset),
            .enable(i < thread_count),
            .core_state(core_state),
            .current_pc(current_pc),
            .next_pc(next_pc[i])
           );
        end
    endgenerate 
    
    
endmodule
