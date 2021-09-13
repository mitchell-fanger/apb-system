`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 12:58:57 PM
// Design Name: 
// Module Name: processor_TB
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


module processor_TB();

    logic nreset;               //reset     
    logic clk;                  //processor clock
    
    //initialization signals
    logic init_done;            //initializing stack program; set HIGH to move out of initialization
    logic [15:0] init_data;            //data to initialize at init_addr
    logic [15:0] init_addr;            //address to initiaze data to
    
    //pwrite to/from apb master
    logic [15:0] wr_data;       //data to write
    logic wr_en;                //write enable
    logic [8:0] wr_addr;        //address to write to, if wr_addr[7] is 0, write to psel1, if wr_addr[7] is high, write to psel2
    logic wr_done;              //flag from master indicating pwrite is complete
    
    //pread to/from apb master
    logic [8:0] rd_addr;              //address to read from
    logic rd_en;                //read enable
    logic [15:0] rd_data;       //data read from apb master
    logic rd_done;              //flag from master indicating pread is complete
    
    //alu inputs/outputs
    logic alu_enable;           //enables alu
    logic alu_control;          //indicates alu operation; 0 for ADD, 1 for SUB
    logic [15:0] A;             //data register A
    logic [15:0] B;             //data register B
    logic [15:0] alu_output;    //output from alu operation
    
    logic kmiintr;              //kmi interrupt signal, from kmi peripheral
    
    processor dut(.*);
    
    assign alu_output = A;
    
    always 
        #5 clk = ~clk;
        
    initial begin
        clk = 0;
        init_done = 0;
        init_addr = 16'h0020;
        init_data = 16'h0000;
        alu_output = 16'h0000;
        nreset = 1;
        wr_done = 0;
        rd_done = 0;
        kmiintr = 0;
        
        #25 nreset = 0;
        #25 nreset = 1;
        
        #20
        
        //initialize stack memory for program 1
        //0x020: MVI A, 0x0013
        //0x022: MVI B, 0x0008
        //0x024: ADD
        //0x025: MOV A, B
        //0x027: LOAD A, 0x0022
        //0x029: STORE 0x0024, B
        //0x02B: HALT
        init_addr = 16'h0020;       //stack[0x0020] = 0x3000, 0x0013; MVI reg A, 0x0013
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0021;
        init_data = 16'h0013;    
        
        #20
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x3001, 0x0008; MVI reg B, 0x0008
        init_data = 16'h3001; 
        #20      
        init_addr = 16'h0023;
        init_data = 16'h0008;   
        
        #20   
        
        init_addr = 16'h0024;       //stack[0x0024] = 0x0000; ADD
        init_data = 16'h0000;
        
        #20
        
        init_addr = 16'h0025;       //stack[0x0022] = 0x2000, 0x0001; MOV reg A, reg B
        init_data = 16'h2000; 
        #20      
        init_addr = 16'h0026;
        init_data = 16'h0001; 
        
        #20
        
        init_addr = 16'h0027;       //stack[0x0027] = 0x4000, 0x0022; LOAD A, 0x0022
        init_data = 16'h4000;
        #20
        init_addr = 16'h0028;       
        init_data = 16'h0022;
        
        #20
        
        init_addr = 16'h0029;       //stack[0x0029] = 0x5022, 0x0001; STORE 0x0022, B
        init_data = 16'h5022;
        #20
        init_addr = 16'h002A;       
        init_data = 16'h0001;
        
        #20
        
        init_addr = 16'h002B;       //stack[0x002B] = 0x8000; HALT
        init_data = 16'h8000;
        
        #20
        
        init_done = 1;
        
        //create kmi interrupt
        #50 kmiintr = 1;
        #50 
        rd_done = 1;
        rd_data = 8'hA1;
        kmiintr = 0;
        
        #200
        rd_done = 0;
        #50
        rd_done = 1;
        #50
        rd_done = 0;
        
        #200
        wr_done = 0;
        #50
        wr_done = 1;
        #50
        wr_done = 0;
        init_done = 0;
        
        #500
        
        //reset processor
        #25 nreset = 0;
        #25 nreset = 1;
        
        #20
        
        //initialize stack memory for program 2
        //0x020: MVI A, 0x0013
        //0x022: MVI B, 0x0008
        //0x024: JMP 0x025 
        //0x025: HALT
        //0x026: MOV A, B
        //0x028: HALT
        init_addr = 16'h0020;       //stack[0x0020] = 0x3000, 0x0013; MVI reg A, 0x0013
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0021;
        init_data = 16'h0013;    
        
        #20
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x3001, 0x0008; MVI reg B, 0x0008
        init_data = 16'h3001; 
        #20      
        init_addr = 16'h0023;
        init_data = 16'h0008;   
        
        #20   
        
        init_addr = 16'h0024;       //stack[0x0024] = 0x6025; JUMP 0x025
        init_data = 16'h6026;
        
        #20
        
        init_addr = 16'h0025;       //stack[0x0025] = 0x8000; HALT
        init_data = 16'h8000;
        
        #20
        
        init_addr = 16'h0026;       //stack[0x0026] = 0x2000, 0x0001; MOV reg A, reg B
        init_data = 16'h2000; 
        #20      
        init_addr = 16'h0027;
        init_data = 16'h0001; 
        
        #20
        
        init_addr = 16'h0028;       //stack[0x0028] = 0x8000; HALT
        init_data = 16'h8000;
        
        #20
        
        init_done = 1;
        #25
        init_done = 0;
        
        #500
        
        //reset processor
        #25 nreset = 0;
        #25 nreset = 1;
        
        #20
        
        //initialize stack memory for program 2
        //0x020: MVI A, 0x0013
        //0x022: MVI B, 0x0000
        //0x024: JEZ 0x028
        //0x025: MOV A, B 
        //0x027: JEZ 0x028
        //0x028: HALT
        //0x029: SUB
        //0x02A: HALT
        init_addr = 16'h0020;       //stack[0x0020] = 0x3000, 0x0013; MVI reg A, 0x0013
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0021;
        init_data = 16'h0013;    
        
        #20
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x3001, 0x0000; MVI reg B, 0x0008
        init_data = 16'h3001; 
        #20      
        init_addr = 16'h0023;
        init_data = 16'h0000;   
        
        #20
        
        init_addr = 16'h0024;       //stack[0x0027] = 0x7029; JEZ 0x029
        init_data = 16'h7029;
        
        #20 
        
        init_addr = 16'h0025;       //stack[0x0025] = 0x2000, 0x0001; MOV reg A, reg B
        init_data = 16'h2000; 
        #20      
        init_addr = 16'h0026;
        init_data = 16'h0001; 
        
        #20  
        
        init_addr = 16'h0027;       //stack[0x0027] = 0x7029; JEZ 0x029
        init_data = 16'h7029;
        
        #20
        
        init_addr = 16'h0028;       //stack[0x0028] = 0x8000; HALT
        init_data = 16'h8000;
        
        #20
        
        init_addr = 16'h0029;       //stack[0x0029] = 0x1000; SUB
        init_data = 16'h1000;
        
        #20
        
        init_addr = 16'h002A;       //stack[0x002A] = 0x8000; HALT
        init_data = 16'h8000;
        
        #20
        
        init_done = 1;
    end

endmodule
