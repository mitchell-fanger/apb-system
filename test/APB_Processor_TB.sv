`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 05:10:56 PM
// Design Name: 
// Module Name: APB_Processor_TB
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


module APB_Processor_TB();

    logic nreset;               //reset     
    logic clk;                  //processor clock
    
    //initialization signals
    logic init_done;            //initializing stack program; set HIGH to move out of initialization
    logic [15:0] init_data;            //data to initialize at init_addr
    logic [15:0] init_addr;            //address to initiaze data to
    
    logic kmiintr;              //kmi interrupt signal, from kmi peripheral
    
    //apb bus inputs/outputs
    logic pready;
    logic [15:0] pr_data;
    logic psel1;                //to select kmi peripheral
    logic psel2;                //to select external memory peripheral
    logic penable;
    logic pwrite;
    logic [7:0] paddr;
    logic [15:0] pw_data;
    
    APB_Processor dut(.*);
    
    always 
        #5 clk = ~clk;
        
    initial begin
        clk = 0;
        init_done = 0;
        init_addr = 16'h0020;
        init_data = 16'h0000;
        nreset = 1;
        pready = 0;
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
        pready = 1;
        kmiintr = 0;
        #50
        pready = 0;
        
        #200

        #50
        pready = 1;
        pr_data = 16'h0027;
        #50
        pready = 0;
        
        #200
        #50
        pready = 1;
        #50
        pready = 0;
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
