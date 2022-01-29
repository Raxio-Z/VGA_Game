`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/16 21:04:07
// Design Name: 
// Module Name: White_Balance
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


module White_Balance(
    input clk,    //时钟
    input white_frequency, //颜色传感器输出的频率
    output reg [63:0] para_red,  //红色对应的参数
    output reg [63:0] para_green,  //绿色对应的参数
    output reg [63:0] para_blue,  //蓝色对应的参数
    output reg [1:0] filter_select,  //对于滤波器的选择
    output ready
    );
    
    reg [63:0]count=0;
    reg [63:0]red_count=0;
    reg [63:0]green_count=0;
    reg [63:0]blue_count=0;
    reg [63:0]init_count=0;   //记录开始时计数器的个数，确保准确
    parameter standard_num=255;
    
    //使用固定红绿蓝周期个数，求出对应的标准时钟个数作为参数
    
    //记录时钟周期
    always @(posedge clk && !ready)
    begin
        count=count+1;    
    end 
    
    always @(posedge white_frequency && !ready)
    begin
         
         //if(red_count==0)
           // init_count=count;
         
         //求红色
         if(red_count<standard_num)
         begin
            red_count=red_count+1;
            filter_select=2'b00;
         end
         else if(red_count==standard_num)
         begin
            red_count=red_count+1;
            para_red=count/*-init_count*/;
            filter_select=2'b11;   //转到绿色
         end
         else
         ;
         
         //求绿色
         if(green_count<standard_num && red_count>standard_num)
         begin
            green_count=green_count+1;
            filter_select=2'b11;
         end
         else if(green_count==standard_num)
         begin
            green_count=green_count+1;
            para_green=count-para_red/*-init_count*/;
            filter_select=2'b10;   //转到蓝色
         end
         else
         ;         

         //求蓝色
         if(blue_count<standard_num && red_count>standard_num && green_count>standard_num)
         begin
            blue_count=blue_count+1;
            filter_select=2'b10;
         end
         else if(blue_count==standard_num)
         begin
            blue_count=blue_count+1;
            para_blue=count-para_red-para_green/*-init_count*/;
         end
         else
         ; 
         
    
    end
    
    assign ready=(red_count>standard_num)&&(green_count>standard_num)&&(blue_count>standard_num);
    
    
endmodule
