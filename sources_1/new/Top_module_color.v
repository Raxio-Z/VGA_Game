`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/23 22:33:54
// Design Name: 
// Module Name: color_top
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


module color_top(
    input clk,
    input frequency,
    output reg is_move,
    output reg [1:0] move,
    output [1:0] filter_out,
    output led,
    output [1:0] frequency_rate
    //output [7:0]blue,
    //output [7:0]green
    );
    
    //reg is_move;
    //reg [1:0]move;
    
    assign frequency_rate=2'b01;
    assign led=1'b1;
    
    wire [63:0] para_red;  //红色对应的参数
    wire [63:0] para_green;  //绿色对应的参数
    wire [63:0] para_blue;  //蓝色对应的参数
    
    //通过创建两个变量来避免在两个always块中对同一个变量赋值导致无法下板的情况
    wire [1:0]filter_banlance;
    wire [1:0]filter_identify;
    
    wire [10:0] red;
    wire [10:0] green;
    wire [10:0] blue;
    
    wire ready;
    
    wire ok;
    
    White_Balance w_b(clk,frequency,para_red,para_green,para_blue,filter_banlance,ready);
    
    Color_Identify c_i(clk,frequency,ready,para_red,para_green,para_blue,red,green,blue,filter_identify,ok);
    
    //最后得到正确的筛选信号
    assign filter_out[0]= ready ? filter_identify[0]:filter_banlance[0];
    assign filter_out[1]= ready ? filter_identify[1]:filter_banlance[1]; 
    
    ///////////////////////////ok需不需要改
    always @(ok)
    begin
    
    if(red<100&&green<100&&blue<100)//黑
    begin
    move=2'b11;
    is_move=1;
    end
    else if(red>180&&green>180&&blue>180)//白
    begin
    is_move=0;
    move=2'b00;
    end
    else if(red>green&&red>blue)//红
    begin
    move=2'b00;
    is_move=1;
    end
    else if(green>red&&green>blue)//绿
    begin
    move=2'b01;
    is_move=1;
    end
    else if(blue>red&&blue>green)//蓝
    begin
    move=2'b10;
    is_move=1;
    end

    else;
    
    
    end 
    
    
    
    
endmodule
