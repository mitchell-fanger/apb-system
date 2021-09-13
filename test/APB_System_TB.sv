`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 06:05:32 PM
// Design Name: 
// Module Name: APB_System_TB
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


module APB_System_TB();

    logic nreset;
    logic clk;
    
    logic init_done;
    logic [15:0] init_data;
    logic [15:0] init_addr;
    
    logic kmirefclk;
    logic kmiclkin;
    logic kmidatain;
    logic kmidataout;
    logic nkmidataen;
    logic nkmiclken;
    
    logic [7:0] pwait;
    
    APB_System dut(.*);
    
    always
        #1 clk = ~clk;
        
    always
        #4 kmirefclk = ~kmirefclk;
        
    always
        #2048 kmiclkin = ~kmiclkin;
        
    initial begin
        clk = 0;
        kmirefclk = 0;
        nreset = 1;
        kmidatain = 1;
        kmiclkin = 0;
        init_done = 0;
        init_addr = 16'h0020;
        init_data = 16'h0000;
        pwait = 8'b00001010;
        
        //reset system
        #5
        nreset = 0;
        #25
        nreset = 1;
        #25
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
        
        #200

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
        
        //initialize stack memory for program 3
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
        
        //initialize stack memory for program 4
        //0x020: MVI A, 0x0013
        //0x022: STORE 0x84, A
        //0x024: MVI A, 0x0004
        //0x026: STORE 0x85, A
        //0x028: MVI A, 0x0A40
        //0x02A: STORE 0x86, A
        //0x02C: LOAD A, 0x84
        //0x02E: LOAD A, 0x85
        //0x030: LOAD A, 0x86
        //0x032: HALT
        init_addr = 16'h0020;       //stack[0x0020] = 0x3000, 0x0013; MVI reg A, 0x0013
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0021;
        init_data = 16'h0013;    
        
        #20
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x5084, 0x0000; STORE 0x84, A
        init_data = 16'h5084; 
        #20      
        init_addr = 16'h0023;
        init_data = 16'h0000; 
          
        #20
        
        init_addr = 16'h0024;       //stack[0x0024] = 0x3000, 0x0004; MVI reg A, 0x0004
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0025;
        init_data = 16'h0004;    
        
        #20
          
        init_addr = 16'h0026;       //stack[0x0026] = 0x5085, 0x0000; STORE 0x85, A
        init_data = 16'h5085; 
        #20      
        init_addr = 16'h0027;
        init_data = 16'h0000;  
        #20
        
        init_addr = 16'h0028;       //stack[0x0028] = 0x3000, 0x0040; MVI reg A, 0x0040
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0029;
        init_data = 16'h0040;    
        
        #20
          
        init_addr = 16'h002A;       //stack[0x002A] = 0x5086, 0x0000; STORE 0x86, A
        init_data = 16'h5086; 
        #20      
        init_addr = 16'h002B;
        init_data = 16'h0000;  
        
        #20     
           
        init_addr = 16'h002C;       //stack[0x002C] = 0x4000, 0x0084; LOAD A, 0x84
        init_data = 16'h4000; 
        #20      
        init_addr = 16'h002D;
        init_data = 16'h0084; 
         
        #20     
           
        init_addr = 16'h002E;       //stack[0x002E] = 0x4000, 0x0085; LOAD A, 0x85
        init_data = 16'h4000; 
        #20      
        init_addr = 16'h002F;
        init_data = 16'h0085;
        #20     
           
        init_addr = 16'h0030;       //stack[0x0030] = 0x4000, 0x0086; LOAD A, 0x86
        init_data = 16'h4000; 
        #20      
        init_addr = 16'h0031;
        init_data = 16'h0086;
        
        #20
        
        init_addr = 16'h0032;       //stack[0x0032] = 0x8000; HALT
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
        
        //initialize stack memory for program 5
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
        
        //initialize stack memory for program 6
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
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x3001, 0x0000; MVI reg B, 0x0000
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
        
        #500
        
        //reset processor
        #25 nreset = 0;
        #25 nreset = 1;
        
        #20
        //initialize stack memory for program 7
        //0x020: MVI A, 0x00CD
        //0x022: MOV B, C
        //0x024: SUB
        //0x025: JEZ 0x027
        //0x026: JMP 0x020
        //0x027: STORE 0x022, C
        //0x029: LOAD A, 0x022
        //0x02B: STORE 0x100, A
        //0x02D: MVI C, 0x0000
        //0x02F: JMP 0x020
        init_addr = 16'h0020;       //stack[0x0020] = 0x3000, 0x0013; MVI reg A, 0x00CD
        init_data = 16'h3000;       
        #20
        init_addr = 16'h0021;
        init_data = 16'h00CD;  
        
        #20
        
        init_addr = 16'h0022;       //stack[0x0022] = 0x2001, 0x0002; MOV reg B, reg C
        init_data = 16'h2001; 
        #20      
        init_addr = 16'h0023;
        init_data = 16'h0002; 
        
        #20
        
        init_addr = 16'h0024;       //stack[0x0024] = 0x1000; SUB
        init_data = 16'h1000; 
        
        #20
        
        init_addr = 16'h0025;       //stack[0x0025] = 0x7027; JEZ 0x027
        init_data = 16'h7027;
        
        #20
        
        init_addr = 16'h0026;       //stack[0x0026] = 0x6020; JMP 0x020
        init_data = 16'h6020;
        
        #20
        
        init_addr = 16'h0027;       //stack[0x0027] = 0x5022, 0x0002; STORE 0x0022, C
        init_data = 16'h5022;
        #20
        init_addr = 16'h0028;       
        init_data = 16'h0002;
        
        #20
        
        init_addr = 16'h0029;       //stack[0x0029] = 0x4000, 0x0022; LOAD A, 0x0022
        init_data = 16'h4000;
        #20
        init_addr = 16'h002A;       
        init_data = 16'h0022;
        
        #20
        
        init_addr = 16'h002B;       //stack[0x002B] = 0x5100, 0x0000; STORE KMI, A
        init_data = 16'h5100;
        #20
        init_addr = 16'h002C;       
        init_data = 16'h0000;
        
        #20
        
        init_addr = 16'h002D;       //stack[0x002D] = 0x3002, 0x0000; MVI reg C, 0x0000
        init_data = 16'h3002;       
        #20
        init_addr = 16'h002E;
        init_data = 16'h0000; 
        
        #20
        init_addr = 16'h002F;       //stack[0x002E] = 0x6020; JMP 0x020
        init_data = 16'h6020;
        
        #20
        init_done = 1;
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
        
        #40960
        #40960
        
        
        //input 0 | 1 0 0 0 0 0 1 1 | 0 | 1 serially; output should be 2'hC1
        //valid input, so receive should go HIGH
        kmidatain = 0; //low start bit
        #4096 kmidatain = 1; //data bit index 0
        #4096 kmidatain = 0; //data bit index 1
        #4096 kmidatain = 0; //data bit index 2
        #4096 kmidatain = 0; //data bit index 3
        #4096 kmidatain = 0; //data bit index 4
        #4096 kmidatain = 0; //data bit index 5
        #4096 kmidatain = 1; //data bit index 6
        #4096 kmidatain = 1; //data bit index 7
        #4096 kmidatain = 0; //parity bit
        #4096 kmidatain = 1; //high stop bit
        
        #40960
        #40960
        
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
        
        #40960
        #40960    
        
        //input 0 | 1 0 1 1 0 0 1 1 | 1 | 1 serially; output should be 2'hCD
        //invalid input, invalid parity bit, so receive should stay LOW
        #4096 kmidatain = 0; //low start bit
        #4096 kmidatain = 1; //data bit index 0
        #4096 kmidatain = 0; //data bit index 1
        #4096 kmidatain = 1; //data bit index 2
        #4096 kmidatain = 1; //data bit index 3
        #4096 kmidatain = 0; //data bit index 4
        #4096 kmidatain = 0; //data bit index 5
        #4096 kmidatain = 1; //data bit index 6
        #4096 kmidatain = 1; //data bit index 7
        #4096 kmidatain = 1; //invalid parity bit
        #4096 kmidatain = 1; //high stop bit
        
        #40960
        #40960

        //input 0 | 1 0 1 1 0 0 1 1 | 0 | 0 serially; output should be 2'hCD
        //invalid input, low stop bit, so receive should stay LOW
        #4096 kmidatain = 0; //low start bit
        #4096 kmidatain = 1; //data bit index 0
        #4096 kmidatain = 0; //data bit index 1
        #4096 kmidatain = 1; //data bit index 2
        #4096 kmidatain = 1; //data bit index 3
        #4096 kmidatain = 0; //data bit index 4
        #4096 kmidatain = 0; //data bit index 5
        #4096 kmidatain = 1; //data bit index 6
        #4096 kmidatain = 1; //data bit index 7
        #4096 kmidatain = 0; //valid parity bit
        #4096 kmidatain = 0; //low stop bit
        #4096 kmidatain = 1; //late high stop bit
    end
    
endmodule
