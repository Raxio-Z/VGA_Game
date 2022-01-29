`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/11 21:53:17
// Design Name: 
// Module Name: VGA_try_tb
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


module VGA_try_tb;

    reg clock;
    wire hs;
    wire vs;
    wire [3:0] Red;
    wire [3:0] Green;
    wire [3:0] Blue;

    reg white_frequency; //颜色传感器输出的频率
    wire [63:0] para_red;  //红色对应的参数
    wire [63:0] para_green;  //绿色对应的参数
    wire [63:0] para_blue;  //蓝色对应的参数
    wire [1:0] filter_select;  //对于滤波器的选择

    VGA_Module uut(clock,hs,vs,Red,Green,Blue);
    //White_Balance WB(clock,white_frequency,para_red,para_green,para_blue,filter_select);
    
    always
    begin
        #0.25
        white_frequency=1;
        #0.25
        white_frequency=0;
   
    end
    
    always
    begin
    #0.125
    clock=1;
    #0.125
    clock=0;  
    end
    

endmodule
