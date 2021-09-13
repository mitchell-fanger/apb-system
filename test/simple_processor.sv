`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/20/2021 08:34:25 PM
// Design Name: 
// Module Name: simple_processor
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

module simple_processor();
 logic [15:0] pc;
 logic [15:0] mem[0:255];
 logic clk;
 
processor dut (.clk(clk), .pc(pc), .mem(mem));
    task add;  //memory write task
        input [7:0]  address;  
        input [7:0] data;  
        begin    
        $display 
        ("%g Register A : %h Data : %h", $time, address,data);    
        $display ("%g  -> Driving CE, WREN, WR data and ADDRESS on to bus", $time);    
        @ (posedge clk);// addr, ce, wren, wr_data are the signals connected to the memory model    
            mem[0] = 'h3000;
            mem[1] = 'h0001;
            mem[2] = 'h3001;
            mem[3] = 'h0003;
            mem[4] = 'h0000;
            mem[5] = 'h0003;
            data = mem[0];
        @ (posedge clk);    
        $display ("======================");  
        end
     endtask
     
     task sub;  //memory read task
        input [7:0]  address;
        input [7:0] data;  
        begin    
        $display ("%g Register A %h: ", $time, address);       
        @ (posedge clk);// addr, ce, wren, wr_data are the signals connected to the memory model    
            mem[0] = 'h3000;
            mem[1] = 'h0001;
            mem[2] = 'h3001;
            mem[3] = 'h0003;
            mem[4] = 'h0001;
            data = mem[0];   
        $display ("======================");  
        end
     endtask
     
     task move;  //memory read task
        input [7:0]  address;
        input [7:0] data;  
        begin    
        $display ("%g Register A %h: ", $time, address);       
        @ (posedge clk);// addr, ce, wren, wr_data are the signals connected to the memory model    
            mem[0] = 'h3000;
            mem[1] = 'h0001;
            mem[2] = 'h3001;
            mem[3] = 'h0003;
            mem[4] = 'h0001;
            data = mem[0];   
        $display ("======================");  
        end
     endtask
     
     initial 
     begin
     clk = 0;
     end
     always 
     #5 clk = ~clk;
     
     initial begin //memory tests
        #1 add(clk, pc);
        @ (posedge clk);
        #1 sub(clk, pc);
        
        #1 move(clk, pc);
        @ (posedge clk);
        #1 mem_read(8'hA1);
        
        #1 mem_write(8'h23, 8'h62);
        @ (posedge clk);
        #1 mem_read(8'h23);
        
        #1 mem_write(8'h46, 8'hAF);
        @ (posedge clk);
        #1 mem_read(8'h46);
        
        #1 mem_write(8'h8A, 8'h12);
        @ (posedge clk);
        #1 mem_read(8'h8A);
     end

endmodule
