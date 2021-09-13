`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 08:13:01 PM
// Design Name: 
// Module Name: memory
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


module memory (clk, addr, ce, wren, rden, wr_data, rd_data);
input clk, ce, wren, rden;input [7:0] addr, wr_data;
    output logic [7:0] rd_data;
    logic [7:0] mem [0:255];
    always @ (posedge clk) 
    if (ce) begin   
    if (rden)        
    rd_data <= mem[addr];   
    else if (wren)        
    mem[addr] <= wr_data;
    end
endmodule
