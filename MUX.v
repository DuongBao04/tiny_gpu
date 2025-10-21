`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 09:20:53 PM
// Design Name: 
// Module Name: MUX
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


module MUX (
    input wire [7:0] op1,
    input wire [7:0] op2,
    input wire [7:0] op3,
    input [1:0] sel,
    
    output [7:0] out_data
    );
    assign out_data = (sel == 2'b00) ? op1 : (sel == 2'b01) ? op2 : op3;
    
endmodule
