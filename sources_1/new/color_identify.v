`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/23 22:31:30
// Design Name: 
// Module Name: Color_Identify
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


//已经白平衡结束，得到了红绿蓝相应参数

module Color_Identify(
    input clk,
    input frequency,
    input ready,
    input [63:0] red_para,
    input [63:0] green_para,
    input [63:0] blue_para,
    output reg [10:0] red,
    output reg [10:0] green,
    output reg [10:0] blue,
    output reg [1:0] filter,
    output ok
    );
    
    
    
    reg [63:0]count=0;
    reg [63:0]red_count=0;
    reg [63:0]green_count=0;
    reg [63:0]blue_count=0;
    reg [63:0]init_count=0;   //记录开始时计数器的个数，确保准确
    
    parameter standard_num=255;    
    parameter standard_value=255;//标准颜色值
    //使用固定红绿蓝周期个数，求出对应的标准时钟个数作为参数
    
    reg reset=0;//复位信号，每次测完一次重新循环
    
    
    //记录时钟周期
    always @(posedge clk && ready)
    begin
    if(!reset)
        count=count+1;    
    else
       count=0;
    end     
    
    always @(posedge frequency && ready)
    begin
         
    if(count==0)
    begin
        red_count=0;
        green_count=0;
        blue_count=0;
        reset=0;
   end
   
   if(count<red_para)
   begin
        filter=2'b00;
        red_count=red_count+1;
   end      
   else if(count>=red_para && count<red_para+green_para)     
   begin
        filter=2'b11;
        green_count=green_count+1;
   end
   else if(count>=red_para+green_para && count<red_para+green_para+blue_para)
   begin
        filter=2'b10;
        blue_count=blue_count+1;
   end
   else if(count>=red_para+green_para+blue_para)
   begin
        red=red_count-1;
        green=green_count-1;
        blue=blue_count-1;
        reset=1;
   end
   else;
    
    end    
    
   assign ok=(count>=red_para+green_para+blue_para)?1:0; 
    
endmodule
