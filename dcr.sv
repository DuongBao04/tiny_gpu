`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2025 08:41:52 AM
// Design Name: 
// Module Name: dcr
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


module dcr(
    input clk, reset,
    
    input device_control_write_enable,
    input [7:0] device_control_data,
    output [7:0] thread_count
    );
    reg [7:0] device_conrol_register;
    assign thread_count = device_conrol_register[7:0];
    
    always @(posedge clk) begin
        if (reset) begin
            device_conrol_register <= 8'b0;
        end else begin
            if (device_control_write_enable) begin 
                device_conrol_register <= device_control_data;
            end
        end
    end    
endmodule
