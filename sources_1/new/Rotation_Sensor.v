`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/27 21:27:56
// Design Name: 
// Module Name: Rotation_Sensor
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

//��ת������ģ�飬ͨ����¼������������ת��ʱ���������Ƕ�
module Rotation_Sensor(//��ת������
    input clk,			//ϵͳʱ��
    input iA,			//��ת������A�ܽ�
    input iB,			//��ת������B�ܽ�
    input SW,			//��ת������D�ܽ�
	input rst,			//��������λ������Ч
	output left,
	output right
);
 
    reg	[1:0] odata; //�������
    
	integer i=0;
//����������Ϊ500us�����Ƽ�ֵ����Ƶ��
	wire clk_2kHZ;
	Divider #50000 divide(clk,rst,clk_2kHZ);//��Ƶ�����ֳ�2kHz

    //�����ݴ�״̬
    reg	 key_a_r;
    reg key_b_r;
    reg key_sw_r;
 
//���A��B��SW�ܽŷֱ�����ȥ��������
//��ÿ������ʱ���ȼ�¼�µ�ǰ����ת״̬���������ݴ������֮����

//����ת�����������뻺�棬��������̬ͬʱ��ʱ����
	always@(posedge clk_2kHZ) begin
		i=i+1;
		key_a_r		<=	iA;//�����ݴ����
		key_b_r		<=	iB;
		if(i==40) begin	//���ڰ����źŲ���20ms���ڲ����ķ�����40*500us = 20ms
			i=0;			
			key_sw_r <= SW;//�����ݴ����
		end 
		else 
			key_sw_r <=	key_sw_r;
	end
 
	reg 	key_sw_r1;//��ʱ�������
	
	//�԰���D�źŽ�����ʱ����
	always@(posedge clk_2kHZ) 	
		key_sw_r1 <= key_sw_r;	
 
	wire	A_state		= key_a_r && iA;	//��ת������A�źŸߵ�ƽ״̬���
	wire	B_state		= key_b_r && iB;	//��ת������B�źŸߵ�ƽ״̬���
 
	reg	 A_state_reg;
	
	//��ʱ����
	always@(posedge clk_2kHZ)
		A_state_reg <= A_state;
	
 
	//��ת������A�źŵ������غ��½��ؼ��
	wire	A_pos	= (!A_state_reg) && A_state;
	wire	A_neg	= A_state_reg && (!A_state);
 
	//ͨ����ת������A�źŵı��غ�B�źŵĵ�ƽ״̬������ж���ת�������Ĳ������������Ӧ�������ź�
	always@(posedge clk_2kHZ or posedge rst)begin
		if(rst==1) odata=2'b00;
		else if(A_pos && !B_state) odata=2'b01;	//������ת  ��ʱ��
		else if(A_neg && B_state) odata=2'b00;
		else if(A_pos && B_state) odata=2'b10;
		else if(A_neg && !B_state) odata=2'b00;    //������ת ˳ʱ��
		else if(key_sw_r1 && (!key_sw_r)) odata=2'b11;		//��ת������D�ź��½��ؼ��odata=2'b00;
		else if ((!key_sw_r1) && key_sw_r)odata=2'b00;  //D�ź������ؽ�������
		else;
	end
    
    assign left=odata[0];
    assign right=odata[1];
    
	endmodule
