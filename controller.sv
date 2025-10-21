`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 04:29:21 PM
// Design Name: 
// Module Name: controller
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


module controller #(
    parameter ADDR_BITS = 8,
    parameter DATA_BITS = 16,
    parameter NUM_CONSUMERS = 4, 
    parameter NUM_CHANNELS = 1,
    parameter WRITE_ENABLE = 1  
)(
    input wire clk,
    input wire reset,
    
    input wire [NUM_CONSUMERS-1:0] consumer_read_request,
    input wire [ADDR_BITS-1:0] consumer_read_address [NUM_CONSUMERS-1:0],
    output reg [NUM_CONSUMERS-1:0] consumer_read_ready,
    output reg [DATA_BITS-1:0] consumer_read_data [NUM_CONSUMERS-1:0],
    input wire [NUM_CONSUMERS-1:0] consumer_write_request,
    input wire [ADDR_BITS-1:0] consumer_write_address [NUM_CONSUMERS-1:0],
    input wire [DATA_BITS-1:0] consumer_write_data [NUM_CONSUMERS-1:0],
    output reg [NUM_CONSUMERS-1:0] consumer_write_ready,
    
    output reg [NUM_CHANNELS-1:0] mem_read_request,
    output reg [ADDR_BITS-1:0] mem_read_address [NUM_CHANNELS-1:0],
    input wire [NUM_CHANNELS-1:0] mem_read_ready,
    input wire [DATA_BITS-1:0] mem_read_data [NUM_CHANNELS-1:0],           
    output reg [NUM_CHANNELS-1:0] mem_write_request,
    output reg [ADDR_BITS-1:0] mem_write_address [NUM_CHANNELS-1:0],
    output reg [DATA_BITS-1:0] mem_write_data [NUM_CHANNELS-1:0],
    input wire [NUM_CHANNELS-1:0] mem_write_ready
    
    );
    localparam IDLE = 3'b000,
            READ_WAITING    = 3'b010,
            WRITE_WAITING   = 3'b011,
            READ_SERVED   = 3'b100,
            WRITE_SERVED  = 3'b101;
    
    reg [2:0] channel_state [NUM_CHANNELS-1:0];
    reg [$clog2(NUM_CONSUMERS)-1:0] current_consumer [NUM_CHANNELS-1:0];
    
    always@(posedge clk) begin
        if (reset) begin
            mem_read_request <= 0;         
            mem_write_request <= 0;

            for (int i = 0; i<NUM_CHANNELS; i++) begin
                mem_read_address[i] <= 0;
                mem_write_address[i] <= 0;
                mem_write_data[i] <= 0;
            end
            
            consumer_read_ready <= 0;
            consumer_write_ready <= 0;
        
            for (int i = 0; i < NUM_CHANNELS; i++) begin
                consumer_read_data[i] <= 0;
                channel_state[i] <= 0;
                current_consumer[i] <= 0;
            end
        end 
        
        else begin
            for (int i = 0; i < NUM_CHANNELS; i = i + 1) begin
                case(channel_state[i])
                    IDLE: begin
                        for (int j = 0; j < NUM_CONSUMERS; j = j + 1) begin
                            if (consumer_read_request[j]) begin
                                current_consumer[i] <= j;
                                
                                mem_read_request[i] <= 1'b1;
                                mem_read_address[i] <= consumer_read_address[j];
                                channel_state[i] <= READ_WAITING;
                                
                                break;
                            end else if (consumer_write_request[j]) begin
                                current_consumer[i] <= j;
                                
                                mem_write_request[i] <= 1'b1;
                                mem_write_address[i] <= consumer_write_address[j];
                                mem_write_data[i] <= consumer_write_data[j];
                                channel_state[i] <= WRITE_WAITING;
                            end
                        end
                    end
                    
                    READ_WAITING: begin
                        if (mem_read_ready[i]) begin
                            mem_read_request[i] <= 1'b0;
                            consumer_read_ready[current_consumer[i]] <= 1;
                            consumer_read_data[current_consumer[i]] <= mem_read_data[i];
                            channel_state[i] <= READ_SERVED;
                        end
                    end
                    
                    WRITE_WAITING: begin
                        if (mem_write_ready[i]) begin
                            mem_write_request[i] <= 0;
                            consumer_write_ready[current_consumer[i]] <= 1;
                            channel_state[i] <= WRITE_SERVED;
                        end
                    end
                    
                    READ_SERVED: begin
                        if (!consumer_read_request[current_consumer[i]]) begin
                            consumer_read_ready[current_consumer[i]] <= 0;
                            channel_state[i] <= IDLE;
                        end
                    end
                    
                    WRITE_SERVED: begin
                        if (!consumer_write_request[current_consumer[i]]) begin
                            consumer_write_ready[current_consumer[i]] <= 0;
                            channel_state[i] <= IDLE;
                        end
                    end
                endcase
            end
        end
    end
    
endmodule
