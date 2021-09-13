`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 12:20:28 PM
// Design Name: 
// Module Name: master_TB
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


module master_TB();

    logic pclk;
    logic presetn;
    logic pready;
    logic [15:0] pr_data;
    
    //outputs to peripherals
    logic psel1;                //to select kmi peripheral
    logic psel2;                //to select external memory peripheral
    logic penable;
    logic pwrite;
    logic [7:0] paddr;
    logic [15:0] pw_data;
    
    //write signals to/from processor
    logic wr_en;                //flag indicating pwrite operation
    logic [8:0] wr_addr;        //write address; wr_addr[8] indicates peripheral; 1 for psel2, 0 for psel1
    logic [15:0] wr_data;       //write data
    logic wr_done;              //flag to processor when write is done
    
    //read signals to/from processor
    logic rd_en;                //request to read data from processor
    logic [8:0] rd_addr;        //address to read from
    logic rd_done;              //flag from processor when data has been read
    logic [15:0] rd_data;       //data sent to processor
    
    master dut(.*);
    
    always
        #5 pclk = ~pclk;
        
    initial begin
        pclk = 0;
        presetn = 1;
        pready = 0;
        wr_en = 0;
        rd_en = 0;
        
        //reset apb master
        #25 presetn = 0;
        #25 presetn = 1;
        
        //perform write operation to psel1; addr = 8'h49; data = 16'hA4B8
        #25
        wr_en = 1;
        wr_addr = 9'b001001001;
        wr_data = 16'hA4B8;
        #25
        //set pready high, wr_en low
        pready = 1;
        #10
        wr_en = 0;
        #25
        //set pready low
        pready = 0;

        //perform write operation to psel2; data = 16'hA4B8
        #25
        wr_en = 1;
        wr_addr = 9'b100000000;
        wr_data = 16'hA4B8;
        #25
        //set pready high, wr_en low
        pready = 1;
        #10
        wr_en = 0;
        #25
        //set pready low
        pready = 0;    
        
        //perform read operation to psel1; addr = 16'h0000
        #25
        rd_en = 1;
        rd_addr = 9'b000000000;
        #25
        //set pready high, wr_en low
        pready = 1;
        #10
        rd_en = 0;
        #25
        //set pready low
        pready = 0;    
        
        //perform read operation to psel2;
        #25
        rd_en = 1;
        rd_addr = 9'b100000000;
        #25
        //set pready high, wr_en low
        pready = 1;
        #10
        rd_en = 0;
        #25
        //set pready low
        pready = 0;     
    
    end
    
    

endmodule
