`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/04 19:59:14
// Design Name: 
// Module Name: Divider
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


module Divider(
    input I_CLK,
    input rst,
    output reg O_CLK
    );
    
    parameter num=20;
    reg [32:0]half=num/2;
    reg [32:0]count=0;
    initial
    begin
    if(count==0)
    O_CLK=0;
    end
always @(posedge I_CLK)
begin

if(rst==1)
begin
O_CLK=0;
count=0;
end
else
begin

count=count+1;
if(count==num)
count=0;
if(count>=0&&count<half)
O_CLK=0;
else //if(count>=half&&count<num)
O_CLK=1;
//else;

end

end
    
    
endmodule
