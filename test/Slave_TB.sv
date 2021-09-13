`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 03:10:16 PM
// Design Name: 
// Module Name: Slave_TB
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


module Slave_TB();
    logic pclk;             //input; abp clock
    logic ref_clk;          //input; kmi internal clock
    logic npreset;          //input; abp reset
    logic pwrite;           //input; abp write enable
    logic psel;             //input; abp select
    logic penable;          //input; abp enable
    logic pready;           //output; abp ready
    logic [7:0] pwdata;     //input; abp write data
    logic [7:0] prdata;     //output; abp read data
    logic [7:0] rx_data;    //input; receive data from receive block
    logic receive;          //input; receive flag from receive block
    logic transmit;         //output; transmit flag to transmit block
    logic [7:0] tx_data;    //output; transmit data to transmit block
    logic tx_done;          //input; transmit done flag from transmit block
    logic rx_done;          //output; receive done flag to receive block
    logic rx_interrupt;     //output; receive interrupt signal to processor
    
    Slave dut(.*);
    
    initial begin
        pclk = 0;
        ref_clk = 0;
        npreset = 1; 
        pwrite = 0; 
        psel = 0;
        penable = 0; 
        pwdata = 8'b00000000;
        rx_data = 8'b00000000;
        receive = 0;
        tx_done = 0;
        
        //reset slave
        #5
        npreset = 0;
        #5
        npreset = 1;
        
        #25
        
        //request to receive from receive block
        rx_data = 8'b01101100;
        receive = 1;
        
        #25
        
        //perform abp read, data = 2'h6C
        psel = 1;
        penable = 1;
        pwrite = 0;
        
        #25
        
        //reset abp signals
        psel = 0;
        penable = 0;
        receive = 0;
        
        #25
        
        //perform abp write, data = 2'h6C
        psel = 1;
        penable = 1;
        pwrite = 1;
        pwdata = 8'b01101100;
        #25
        tx_done = 1;
        
        #25
        
        //reset signals
        psel = 0;
        penable = 0;
        tx_done = 0;

        #25

        //request to receive from receive block
        rx_data = 8'b11011110;
        receive = 1;
        
        #25
        
        //perform abp read, data = 2'hDE
        psel = 1;
        penable = 1;
        pwrite = 0;
        
        #25
        
        //reset abp signals
        psel = 0;
        penable = 0;
        receive = 0;
        
        #25
        
        //perform abp write, data = 2'h05
        psel = 1;
        penable = 1;
        pwrite = 1;
        pwdata = 8'b0000101;
        #25
        tx_done = 1;
        
        #25
        
        //reset signals
        psel = 0;
        penable = 0;
        tx_done = 0;
        
    end
    
    always
        #1 pclk = ~pclk;
        
    always
        #512 ref_clk = ~ref_clk;
    
    
endmodule
