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
    input clk,    //ʱ��
    input white_frequency, //��ɫ�����������Ƶ��
    output reg [63:0] para_red,  //��ɫ��Ӧ�Ĳ���
    output reg [63:0] para_green,  //��ɫ��Ӧ�Ĳ���
    output reg [63:0] para_blue,  //��ɫ��Ӧ�Ĳ���
    output reg [1:0] filter_select,  //�����˲�����ѡ��
    output ready
    );
    
    reg [63:0]count=0;
    reg [63:0]red_count=0;
    reg [63:0]green_count=0;
    reg [63:0]blue_count=0;
    reg [63:0]init_count=0;   //��¼��ʼʱ�������ĸ�����ȷ��׼ȷ
    parameter standard_num=255;
    
    //ʹ�ù̶����������ڸ����������Ӧ�ı�׼ʱ�Ӹ�����Ϊ����
    
    //��¼ʱ������
    always @(posedge clk && !ready)
    begin
        count=count+1;    
    end 
    
    always @(posedge white_frequency && !ready)
    begin
         
         //if(red_count==0)
           // init_count=count;
         
         //���ɫ
         if(red_count<standard_num)
         begin
            red_count=red_count+1;
            filter_select=2'b00;
         end
         else if(red_count==standard_num)
         begin
            red_count=red_count+1;
            para_red=count/*-init_count*/;
            filter_select=2'b11;   //ת����ɫ
         end
         else
         ;
         
         //����ɫ
         if(green_count<standard_num && red_count>standard_num)
         begin
            green_count=green_count+1;
            filter_select=2'b11;
         end
         else if(green_count==standard_num)
         begin
            green_count=green_count+1;
            para_green=count-para_red/*-init_count*/;
            filter_select=2'b10;   //ת����ɫ
         end
         else
         ;         

         //����ɫ
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
