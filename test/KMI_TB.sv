`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2021 12:44:51 PM
// Design Name: 
// Module Name: KMI_TB
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


module KMI_TB();
    logic kmiintr;          //output; interrupt signal to processor
    logic kmirefclk;        //input; internal kmi clock
    logic nkmirst;          //input; reset
    logic kmidatain;        //input; k/m serial data input
    logic kmidataout;       //output; k/m serial data output
    logic nkmidataen;       //output; k/m data enable
    logic kmiclkin;         //input; k/m clock
    logic nkmiclken;        //output; k/m clock enable, not used?
    logic pclk;             //input; abp system clock
    logic pwrite;           //input; write enable
    logic psel;             //input; select enable
    logic penable;          //input; enable signal
    logic pready;           //output; ready signal
    logic [7:0] pwdata;     //input; data to transmit
    logic [7:0] prdata;     //output; data to receive
    
    KMI dut(.*);
    
    initial begin
        kmirefclk = 0;
        nkmirst = 1;
        kmidatain = 1;
        kmiclkin = 0;
        pclk = 0;
        pwrite = 0;
        psel = 0;
        penable = 0;
        pwdata = 8'b00000000;
        
        //reset kmi
        #5
        nkmirst = 0;
        #25
        nkmirst = 1;
        
        //input 0 | 1 0 1 1 0 0 1 1 | 0 | 1 serially; output should be 2'hCD
        //valid input, so receive should go HIGH
        kmidatain = 0; //low start bit
        #4096 kmidatain = 1; //data bit index 0
        #4096 kmidatain = 0; //data bit index 1
        #4096 kmidatain = 1; //data bit index 2
        #4096 kmidatain = 1; //data bit index 3
        #4096 kmidatain = 0; //data bit index 4
        #4096 kmidatain = 0; //data bit index 5
        #4096 kmidatain = 1; //data bit index 6
        #4096 kmidatain = 1; //data bit index 7
        #4096 kmidatain = 0; //parity bit
        #4096 kmidatain = 1; //high stop bit

        #8192
        
        //perform abp read, data = 2'h6C
        psel = 1;
        penable = 1;
        pwrite = 0;
        
        #25
        
        //reset abp signals
        psel = 0;
        penable = 0;
        
        //perform abp write
        #8192
        psel = 1;
        penable = 1;
        pwrite = 1;
        pwdata = 8'b01101100;
        
        #81920
        
        //reset signals
        psel = 0;
        penable = 0;
    end
    
    always
        #1 pclk = ~pclk;
        
    always
        #4 kmirefclk = ~kmirefclk;
        
    always
        #2048 kmiclkin = ~kmiclkin;

endmodule
