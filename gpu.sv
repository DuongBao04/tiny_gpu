`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/20/2025 12:58:05 PM
// Design Name: 
// Module Name: gpu
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


module gpu #(
    parameter DATA_MEM_ADDR_BITS = 8,       // Number of bits in data memory address (256 rows)
    parameter DATA_MEM_DATA_BITS = 8,       // Number of bits in data memory value (8 bit data)
    parameter DATA_MEM_NUM_CHANNELS = 4,    // Number of concurrent channels for sending requests to data memory
    parameter INSTRUCTION_MEM_ADDR_BITS = 8,     // Number of bits in instruction memory address (256 rows)
    parameter INSTRUCTION_MEM_DATA_BITS = 16,    // Number of bits in instruction memory value (16 bit instruction)
    parameter INSTRUCTION_MEM_NUM_CHANNELS = 1,  // Number of concurrent channels for sending requests to instruction memory
    parameter NUM_CORES = 2,                 // Number of cores to include in this GPU
    parameter THREADS_PER_BLOCK = 4 
)(
    input clk, reset,
    
    // Kernel Execution
    input  start,
    output done,
    
    // Device Control Register
    input device_control_write_enable,
    input [7:0] device_control_data,
    
    // Program Memory
    output wire [INSTRUCTION_MEM_NUM_CHANNELS-1:0] instruction_mem_read_request,
    output wire [INSTRUCTION_MEM_ADDR_BITS-1:0] instruction_mem_read_address [INSTRUCTION_MEM_NUM_CHANNELS-1:0],
    input wire [INSTRUCTION_MEM_NUM_CHANNELS-1:0] instruction_mem_read_ready,
    input wire [INSTRUCTION_MEM_DATA_BITS-1:0] instruction_mem_read_data [INSTRUCTION_MEM_NUM_CHANNELS-1:0],

    // Data Memory
    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_request,
    output wire [DATA_MEM_ADDR_BITS-1:0] data_mem_read_address [DATA_MEM_NUM_CHANNELS-1:0],
    input wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_ready,
    input wire [DATA_MEM_DATA_BITS-1:0] data_mem_read_data [DATA_MEM_NUM_CHANNELS-1:0],
    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_request,
    output wire [DATA_MEM_ADDR_BITS-1:0] data_mem_write_address [DATA_MEM_NUM_CHANNELS-1:0],
    output wire [DATA_MEM_DATA_BITS-1:0] data_mem_write_data [DATA_MEM_NUM_CHANNELS-1:0],
    input wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_ready
    
    
    );
    
    // Control
    wire [7:0] thread_count;
    
    // Computer Core State
    wire [NUM_CORES-1:0] core_start;
    wire [NUM_CORES-1:0] core_reset;
    wire [NUM_CORES-1:0] core_done;
    wire [7:0] core_block_id [NUM_CORES-1:0];
    wire [$clog2(THREADS_PER_BLOCK)-1:0] core_thread_count [NUM_CORES-1:0];
    
    //Lsu and Data memory
    localparam NUM_LSUS = NUM_CORES * THREADS_PER_BLOCK;
    reg [NUM_LSUS-1:0] lsu_read_request;
    reg [DATA_MEM_ADDR_BITS-1:0] lsu_read_address [NUM_LSUS-1:0];
    reg [NUM_LSUS-1:0] lsu_read_ready;
    reg [DATA_MEM_DATA_BITS-1:0] lsu_read_data [NUM_LSUS-1:0];
    reg [NUM_LSUS-1:0] lsu_write_request;
    reg [DATA_MEM_ADDR_BITS-1:0] lsu_write_address [NUM_LSUS-1:0];
    reg [DATA_MEM_DATA_BITS-1:0] lsu_write_data [NUM_LSUS-1:0];
    reg [NUM_LSUS-1:0] lsu_write_ready;
    
    // Fetcher <> Instruction Memory controller channels
    localparam NUM_FETCHERS = NUM_CORES;
    wire [NUM_FETCHERS-1:0] fetcher_read_request;
    wire [INSTRUCTION_MEM_ADDR_BITS-1:0] fetcher_read_address [NUM_FETCHERS-1:0];
    wire [NUM_FETCHERS-1:0] fetcher_read_ready;
    wire [INSTRUCTION_MEM_DATA_BITS-1:0] fetcher_read_data [NUM_FETCHERS-1:0]; 
    
    dcr dcr_instance (
        .clk(clk),
        .reset(reset),
        
        .device_control_write_enable(device_control_write_enable),
        .device_control_data(device_control_data),
        .thread_count(thread_count)
    );
    
    // Data Memory Controller
    controller #(
        .ADDR_BITS(DATA_MEM_ADDR_BITS),
        .DATA_BITS(DATA_MEM_DATA_BITS),
        .NUM_CONSUMERS(NUM_LSUS),
        .NUM_CHANNELS(DATA_MEM_NUM_CHANNELS)
    ) data_memory_controller (
        .clk(clk),
        .reset(reset),
        
        .consumer_read_request(lsu_read_request),
        .consumer_read_address(lsu_read_address),
        .consumer_read_ready(lsu_read_ready),
        .consumer_read_data(lsu_read_data),
        .consumer_write_request(lsu_write_request),
        .consumer_write_address(lsu_write_address),
        .consumer_write_data(lsu_write_data),
        .consumer_write_ready(lsu_write_ready),

        .mem_read_request(data_mem_read_request),
        .mem_read_address(data_mem_read_address),
        .mem_read_ready(data_mem_read_ready),
        .mem_read_data(data_mem_read_data),
        .mem_write_request(data_mem_write_request),
        .mem_write_address(data_mem_write_address),
        .mem_write_data(data_mem_write_data),
        .mem_write_ready(data_mem_write_ready)
    );
    
    // Dispatcher
    dispatcher #(
        .NUM_CORES(NUM_CORES),
        .THREADS_PER_BLOCK(THREADS_PER_BLOCK)
    ) dispatcher (
        .clk(clk),
        .reset(reset),
        .start(start),
        .thread_count(thread_count),
        .core_done(core_done),
        .core_start(core_start),
        .core_reset(core_reset),
        .core_block_id(core_block_id),
        .core_thread_count(core_thread_count),
        .done(done)
    );
    
    
    
    genvar i;
    generate
        for (i = 0; i < NUM_CORES; i = i + 1) begin : cores
            reg [THREADS_PER_BLOCK-1:0] core_lsu_read_request;
            reg [DATA_MEM_ADDR_BITS-1:0] core_lsu_read_address [THREADS_PER_BLOCK-1:0];
            reg [THREADS_PER_BLOCK-1:0] core_lsu_read_ready;
            reg [DATA_MEM_DATA_BITS-1:0] core_lsu_read_data [THREADS_PER_BLOCK-1:0];
            reg [THREADS_PER_BLOCK-1:0] core_lsu_write_request;
            reg [DATA_MEM_ADDR_BITS-1:0] core_lsu_write_address [THREADS_PER_BLOCK-1:0];
            reg [DATA_MEM_DATA_BITS-1:0] core_lsu_write_data [THREADS_PER_BLOCK-1:0];
            reg [THREADS_PER_BLOCK-1:0] core_lsu_write_ready;
            
            genvar j;
            for (j = 0; j < THREADS_PER_BLOCK; j = j - 1) begin
                localparam lsu_index = i * THREADS_PER_BLOCK + j;
                always @(posedge clk) begin 
                    lsu_read_request[lsu_index] <= core_lsu_read_request[j];
                    lsu_read_address[lsu_index] <= core_lsu_read_address[j];

                    lsu_write_request[lsu_index] <= core_lsu_write_request[j];
                    lsu_write_address[lsu_index] <= core_lsu_write_address[j];
                    lsu_write_data[lsu_index] <= core_lsu_write_data[j];
                    
                    core_lsu_read_ready[j] <= lsu_read_ready[lsu_index];
                    core_lsu_read_data[j] <= lsu_read_data[lsu_index];
                    core_lsu_write_ready[j] <= lsu_write_ready[lsu_index];
                end
            end
            
            
            //Computer core
            core core_instance(
                .clk(clk),
                .reset(core_reset[i]),
                .start(core_start[i]),
                .done(core_done[i]),
                .block_id(core_block_id[i]),
                .thread_count(core_thread_count[i]),
                
                .instruction_mem_read_request(fetcher_read_request[i]),
                .instruction_mem_read_address(fetcher_read_address[i]),
                .instruction_mem_read_ready(fetcher_read_ready[i]),
                .instruction_mem_read_data(fetcher_read_data[i]),

                .data_mem_read_request(core_lsu_read_request),
                .data_mem_read_address(core_lsu_read_address),
                .data_mem_read_ready(core_lsu_read_ready),
                .data_mem_read_data(core_lsu_read_data),
                .data_mem_write_request(core_lsu_write_request),
                .data_mem_write_address(core_lsu_write_address),
                .data_mem_write_data(core_lsu_write_data),
                .data_mem_write_ready(core_lsu_write_ready)
            );
        end
            
    endgenerate
    
    
endmodule
