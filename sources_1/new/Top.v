`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/27 23:49:33
// Design Name: 
// Module Name: Top
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




module Top(
input clk,
input sig,
input sw,//复位信号，为0时复位
input sa,//左
input sb,//右
input frequency,
output  hs,
output  vs,
output  [3:0] Red,
output  [3:0] Green,
output  [3:0] Blue,
output left_test,
output right_test,
output [1:0] filter_out,
output led,
output [1:0] frequency_rate
    );
    

    
    wire left;//逆时针，对应向左
    wire right;//顺时针  对应向右

    wire is_end;
    
    reg signed [15:0]sin_alpha;
    reg signed [15:0]cos_alpha;
    
    wire rst=0;
        
    assign left_test=left;
    assign right_test=right;
    
    wire is_move;
    wire [1:0]move;
    
     color_top Color(clk,frequency,is_move,move,filter_out,led,filter_rate);
     Rotation_Sensor  rotate(clk,sa,sb,sw,rst,left,right);
     VGA_Module vga(clk,left,right,is_move,move,sig,hs,vs,Red,Green,Blue,is_end);
     
     reg [1:0]state;
     parameter idle=2'b00,start=2'b01,stop=2'b10;
     always@(posedge clk)
     begin
     
     case (state)
     idle:begin
        if(is_move ||left||right)
        state=start;
        else
        state=idle;
        end
     start:begin
        if(is_end==1)
        state=stop;
        else
        state=start;
        end
     stop:begin
        if(sig==1)
        state=idle;
        else
        state=stop;
        end
     endcase
               
     end
     
endmodule
