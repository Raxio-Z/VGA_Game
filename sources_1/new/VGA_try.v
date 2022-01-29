`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/11 19:36:37
// Design Name: 
// Module Name: VGA_Module
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


module VGA_Module(
    input clock,
    input left,//逆时针
    input right,//顺时针
    input is_move,
    input [1:0]move,
    input sig,
    output reg hs,
    output reg vs,
    output reg [3:0] Red,
    output reg [3:0] Green,
    output reg [3:0] Blue,
    output reg is_end
    );
    // 分辨率为640*480时行时序各个参数定义
    parameter      H_SYNC_PULSE      =   96  , 
                    H_BACK_PORCH      =   48  ,
                    H_ACTIVE_TIME     =   640 ,
                    H_FRONT_PORCH     =   16  ,
                    H_LINE_PERIOD     =   800 ;
    
    // 分辨率为640*480时场时序各个参数定义               
    parameter     V_SYNC_PULSE      =   2   , 
                    V_BACK_PORCH      =   33  ,
                    V_ACTIVE_TIME     =   480 ,
                   V_FRONT_PORCH     =   10  ,
                   V_FRAME_PERIOD    =   525 ;
   //实验，将屏幕分成8快             
   parameter       COLOR_BAR_WIDTH   =   H_ACTIVE_TIME / 8  ;                 




    wire active_flag;//激活信号   为1时才可以显示
   reg [11:0]      h_count=0         ; // 行时序计数器
   reg [11:0]      v_count=0         ; // 列时序计数器
   
   reg   clk_50M=0;
   reg    clk_25M =0;
    
   //产生50MHz频率
   always @(posedge clock)
   begin
        clk_50M=~clk_50M;
   end 
   //产生25MHz的基准时钟
   always  @(posedge clk_50M)
   begin
        clk_25M=~clk_25M;
   end
   
   	wire clk_100HZ;
   	wire rst=0;
   Divider #1000000 divide(clock,rst,clk_100HZ);//分频器，分成100Hz
   
   //设置行计数器
   always @(posedge clk_25M)
   begin
       
       if(h_count<H_SYNC_PULSE)
       hs=0;
       else
       hs=1;       
              
        if(h_count == H_LINE_PERIOD - 1)
        h_count=0;
        else
        h_count=h_count+1;
        
        
   end
   
   
   //产生场时序
   always @(posedge clk_25M)
   begin
        if(v_count<V_SYNC_PULSE)
        vs=0;
        else
        vs=1;
        
        if(v_count==V_FRAME_PERIOD-1)
        v_count=0;
        else if(h_count==H_LINE_PERIOD - 1)
        v_count=v_count+1;
        else 
        v_count=v_count;
       
   end
   
   //必须在active区间内才我那个屏幕上进行输出
   assign active_flag =  (h_count >= (H_SYNC_PULSE + H_BACK_PORCH                  ))  &&
                           (h_count <= (H_SYNC_PULSE + H_BACK_PORCH + H_ACTIVE_TIME))  && 
                           (v_count >= (V_SYNC_PULSE + V_BACK_PORCH                  ))  &&
                           (v_count <= (V_SYNC_PULSE + V_BACK_PORCH + V_ACTIVE_TIME))  ;
   
   parameter Line_base=H_SYNC_PULSE+H_BACK_PORCH;
   parameter Column_base=V_SYNC_PULSE+V_BACK_PORCH;   
   parameter half_thick = 6;
   parameter length = 100;
   parameter r_ball = 10;
   parameter speed_ball = 10;
   parameter speed_board = 40;
   parameter pi = 314;
   parameter float_transfer=100;
   
   
   reg [10:0]x_center = Line_base + H_ACTIVE_TIME/2;
   reg [10:0]y_center = Column_base + V_ACTIVE_TIME/2;
   reg [10:0]x_ball = Line_base + H_ACTIVE_TIME/2;
   reg [10:0]y_ball = Column_base + V_ACTIVE_TIME/2 - 60;
   reg signed [15:0]dis;
   reg signed [15:0]dis2;
   reg signed [15:0]alpha = 300;
   reg [15:0]temp_alpha;//用作中途计算之需
   reg signed [15:0]sin_alpha = 0;
   reg signed [15:0]cos_alpha = float_transfer;//float_transfer;//问题是现在这个位数太少，只有6位，最多64，存不下来
   reg signed [15:0]theta = 0;
   reg [15:0]temp_theta = 0;//用作中途计算之需
   reg signed [15:0]sin_theta = 0;
   reg signed [15:0]cos_theta = float_transfer;//用来标记cos(theta)的正负

   
   
   reg signed [15:0]dis_temp1;
   reg signed [15:0]dis_temp2;
   
   //修改角度alpha的值
   
   always @ (posedge clk_100HZ)
   begin
   
   if(is_end==1)   
   alpha=alpha;
   
else
begin   
   if(left==1 && right==0)
   alpha = alpha + 1;
   else if(left==0 && right==1)
   alpha = alpha - 1;
   else if(left==0 && right==0)
   alpha = alpha;
   else
   alpha=0;
   
   if(alpha>pi)
   alpha=alpha-pi;
   else if(alpha<0)
   alpha=alpha+pi;
   else;
end   
   
   end
   
   
   //修改sin和cos的值
   //此处不能用 POSedge，，，不是时钟，需要注意，，，很隐蔽 的错误
   
   always@(alpha)
   begin
        
     //根据alpha和theta的位置给出相应的sin和cos正负 并给出其值  
     if(alpha>=0&&alpha<pi/2)
     begin
     temp_alpha=alpha;
     sin_alpha=((temp_alpha)-float_transfer*temp_alpha*temp_alpha*temp_alpha/(float_transfer*float_transfer*float_transfer)/6+float_transfer*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/120-float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/5040);
     cos_alpha=(float_transfer-float_transfer*(temp_alpha*temp_alpha)/(float_transfer*float_transfer)/2+float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer)/24-float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/720);
     

     end
     else if(alpha>=pi/2 && alpha<pi)
     begin
     temp_alpha=alpha-pi/2;
     sin_alpha=(float_transfer-float_transfer*(temp_alpha*temp_alpha)/(float_transfer*float_transfer)/2+float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer)/24-float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/720);
     cos_alpha=-((temp_alpha)-float_transfer*temp_alpha*temp_alpha*temp_alpha/(float_transfer*float_transfer*float_transfer)/6+float_transfer*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/120-float_transfer*(temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha*temp_alpha)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/5040);   

          
     end
    
   end


//给出画板子的四个角的位置
    reg signed [15:0]x_left;
    reg signed [15:0]y_left;
    reg signed [15:0]x_right;
    reg signed [15:0]y_right;
    reg signed [15:0]x_cir1;
    reg signed [15:0]x_cir2;
    reg signed [15:0]y_cir1;
    reg signed [15:0]y_cir2;
    
    always@(*)
    begin
    if(alpha>=0 && alpha<pi/2)
    begin
    x_left=x_center*float_transfer - (length / 2) * cos_alpha - half_thick*sin_alpha;
    x_right=x_center*float_transfer + (length / 2) * cos_alpha  + half_thick*sin_alpha;
    y_left=y_center*float_transfer - (length / 2) * sin_alpha  - half_thick*cos_alpha;
    y_right=y_center*float_transfer + (length / 2) * sin_alpha  + half_thick*cos_alpha;
    end
    else if(alpha>=pi/2 && alpha<pi)
    begin
    x_left=x_center*float_transfer + (length / 2) * cos_alpha  - half_thick*sin_alpha;
    x_right=x_center*float_transfer - (length / 2) * cos_alpha + half_thick*sin_alpha;
    y_left=y_center*float_transfer - (length / 2) * sin_alpha  + half_thick*cos_alpha;
    y_right=y_center*float_transfer + (length / 2) * sin_alpha  - half_thick*cos_alpha;
    end
    else;
    

    x_cir1=x_center*float_transfer + (length / 2) * cos_alpha;
    y_cir1=y_center*float_transfer - (length / 2) * sin_alpha;
    x_cir2=x_center*float_transfer - (length / 2) * cos_alpha;
    y_cir2=y_center*float_transfer + (length / 2) * sin_alpha;
    
    //dis=(y_center - v_count) * cos_alpha + (x_center - h_count)* sin_alpha;
    //dis2=(y_center - v_count) * sin_alpha - (x_center - h_count)* cos_alpha;
    
    end

  
   //修改 x_center和y_cneter的值
   //应该最终改成如果有输入信号的变化，，上下左右或者旋转

   always @ (posedge clk_100HZ)
   begin
if(is_end==1)
begin
   x_center=x_center;
   y_center=y_center;
end
   
else
begin
   dis_temp1=(y_ball - y_center) * cos_alpha + (x_ball - x_center)* sin_alpha;
   dis_temp2=(y_ball - y_center) * sin_alpha - (x_ball - x_center)* cos_alpha;
   /*if((dis_temp1<=(r_ball + half_thick)*float_transfer) && (dis_temp1 >= -(r_ball + half_thick)*float_transfer) && (dis_temp2<=(float_transfer*length/2)) && (dis_temp2 >= -(float_transfer*length/2)))
   begin
   
   x_center=x_center;
   y_center=y_center;
   
   end  
   
   else
   begin*/
   
   if(is_move==1)
   begin
        if(move==2'b00)//红色，向左
            if(x_center<Line_base + H_ACTIVE_TIME/10 + length / 2 + 20)
            x_center=x_center;
            else
            x_center=x_center-1;
        else if(move==2'b11) //黑色，向右
            if(x_center>Line_base + 9*H_ACTIVE_TIME/10 - length / 2 - 20)
            x_center=x_center;
            else
            x_center=x_center+1;
        else ;
   
   end   
   else;//白色，不动   
      
           
   if(is_move==1)
   begin
        if(move==2'b01)//绿色 向下
            if(y_center>Column_base + 9*V_ACTIVE_TIME/10 - half_thick - 20)
            y_center=y_center;
            else
            y_center=y_center+1;
        else if(move==2'b10)//蓝色，向上
            if(y_center<Column_base + V_ACTIVE_TIME/10 + half_thick + 20)
            y_center=y_center;
            else        
            y_center=y_center-1;
        else;
          
   end   
    else;//白色，不动      
      
   //end//与是否相撞的对应
end   
   end
   
   //修改球的角度
   always @(posedge clk_100HZ)
   begin
   
if(is_end==1)
theta=theta;   

else
begin   
   if(x_ball<=Line_base + H_ACTIVE_TIME/10 &&cos_theta<0)
   theta=pi-theta;
   else if(x_ball>=Line_base + 9*H_ACTIVE_TIME/10 &&cos_theta>0)
   theta=pi-theta;
   else if(y_ball<=Column_base + V_ACTIVE_TIME/10 && sin_theta<0)
   theta=2*pi-theta;
   else if(y_ball>=Column_base + 9*V_ACTIVE_TIME/10 && sin_theta>0)
   theta=2*pi-theta;
   else if((dis_temp1<=(r_ball + half_thick)*float_transfer) && (dis_temp1 >= -(r_ball + half_thick)*float_transfer) && (dis_temp2<=(float_transfer*length/2)) && (dis_temp2 >= -(float_transfer*length/2)))
   theta=2*pi-theta-alpha;
   else;

   
   if(theta<0)
   theta=theta+2*pi;
   else if(theta>2*pi)
   theta=theta-2*pi;

end
   
     if((theta>=0&&theta<pi/2)||(theta>=pi&&theta<3*pi/2))
      begin
      if(theta>=0&&theta<pi/2)
       temp_theta=theta;
       else if(theta>=pi&&theta<3*pi/2)
       temp_theta=theta-pi;
       else;
       
      sin_theta=((temp_theta)-float_transfer*temp_theta*temp_theta*temp_theta/(float_transfer*float_transfer*float_transfer)/6+float_transfer*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/120-float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/5040);
      cos_theta=(float_transfer-float_transfer*(temp_theta*temp_theta)/(float_transfer*float_transfer)/2+float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer)/24-float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/720);  
      
      if(theta>=pi&&theta<3*pi/2)  
      begin
      sin_theta=-sin_theta;
      cos_theta=-cos_theta;
      end
      
      end
      else if((theta>=pi/2&&theta<pi)||(theta>=3*pi/2)&&theta<2*pi)
      begin
      
      if(theta>=pi/2&&theta<pi)
       temp_theta=theta-pi/2;
       else if(theta>=3*pi/2&&theta<2*pi)
       temp_theta=theta-pi/2-pi;
       else;
       
      sin_theta=(float_transfer-float_transfer*(temp_theta*temp_theta)/(float_transfer*float_transfer)/2+float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer)/24-float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/720);
      cos_theta=-((temp_theta)-float_transfer*temp_theta*temp_theta*temp_theta/(float_transfer*float_transfer*float_transfer)/6+float_transfer*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/120-float_transfer*(temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta*temp_theta)/(float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer*float_transfer)/5040);
      
     if(theta>=3*pi/2&&theta<2*pi) 
      begin
      sin_theta=-sin_theta;
      cos_theta=-cos_theta;        
      end
      
      end
   
       else;   
   
   
   end

   //修改球坐标
   reg [10:0]x_counter=1;
   reg [10:0]y_counter=1;
   reg signed [10:0]x_accu=0;
   reg signed [10:0]y_accu=0;
   reg signed [18:0]x_100ball=(Line_base + H_ACTIVE_TIME/2)*100;
   reg signed [18:0]y_100ball=(Column_base + V_ACTIVE_TIME/2 - 60)*100;
   	wire clk_50HZ;

Divider #2000000 divide2(clock,rst,clk_50HZ);//分频器，分成100Hz   
   
   always@(posedge clk_50HZ)
   begin

if(is_end==1)
begin
x_100ball=x_100ball;
y_100ball=y_100ball;
end  
else
begin 
      if(x_ball<=Line_base + H_ACTIVE_TIME/10&&cos_theta<0)
      x_100ball=(Line_base + H_ACTIVE_TIME/10+1)*100;

   else if(x_ball>=Line_base + 9*H_ACTIVE_TIME/10&&cos_theta>0)
      x_100ball=(Line_base + 9*H_ACTIVE_TIME/10-1)*100;
   else if(y_ball<=Column_base + V_ACTIVE_TIME/10&&sin_theta<0)
      y_100ball=(Column_base + V_ACTIVE_TIME/10+1)*100;
      
   else if(y_ball>=Column_base + 9*V_ACTIVE_TIME/10&&sin_theta>0)
      y_100ball=(Column_base + 9*V_ACTIVE_TIME/10-1)*100;
   else if((dis_temp1<=(r_ball + half_thick)*float_transfer) && (dis_temp1 >= -(r_ball + half_thick)*float_transfer) && (dis_temp2<=(float_transfer*length/2)) && (dis_temp2 >= -(float_transfer*length/2)))
   begin
   x_counter=1;
   y_counter=1;   
   end
   else
    begin
   
   x_100ball=x_100ball+cos_theta;
   y_100ball=y_100ball+sin_theta;
   end
end   
   
   x_ball=x_100ball/100;
   y_ball=y_100ball/100;
   
   end
   
   
//修改is_end的值   
always @(*)
begin

if(sig==0)
begin
if(x_ball>=Line_base + 9*H_ACTIVE_TIME/10-1 && y_ball>=Column_base + 4*V_ACTIVE_TIME/10&&y_ball<=Column_base + 6*V_ACTIVE_TIME/10)
is_end=1;
else
is_end=0;
end
else
is_end=0;


end
   
   
   
   //改动RGB的值，进行输出
   always @ (*)
   begin
   if(active_flag)
   begin
            //专门描绘边缘
            if((v_count>Column_base + V_ACTIVE_TIME/10) && (v_count<Column_base + 9*V_ACTIVE_TIME/10)&&((h_count<Line_base + H_ACTIVE_TIME/10) || (h_count>Line_base + 9*H_ACTIVE_TIME/10 && (v_count<Column_base + 4*V_ACTIVE_TIME/10 || v_count>Column_base + 6*V_ACTIVE_TIME/10))))
            begin  //边缘蓝色（留一个空）
                        if(is_move==1)
                           begin
                           
                               if(move==2'b00)//红色，向左
                               begin
                               Red   =  4'b1111    ;
                               Green =  4'b0000   ;
                               Blue  =  4'b0000    ;                    
                           
                               end
                               else if(move==2'b11) //黑色，向右
                               begin
                               Red   =  4'b0111    ;
                               Green =  4'b0011   ;
                               Blue  =  4'b0001    ;                    
                                              
                               end
                               else if(move==2'b01)//绿色 向下
                               begin
                               Red   =  4'b0000    ;
                               Green =  4'b1111   ;
                               Blue  =  4'b0000    ;                    
                                              
                               end
                               else if(move==2'b10)//蓝色，向上
                               begin
                               Red   =  4'b0000    ;
                               Green =  4'b0000   ;
                               Blue  =  4'b1111    ;                    
                                              
                               end
                               else;
                           end
                           else 
                           begin
                               Red   =  4'b1111    ;
                               Green =  4'b1111   ;
                               Blue  =  4'b1111    ;                    
                                                                                    
                           end            
                //Red   =  4'b0000    ;
                //Green =  4'b1111   ;
                //Blue  =  4'b0000    ;                           
            end
            else if((v_count<Column_base + V_ACTIVE_TIME/10) || (v_count>Column_base + 9*V_ACTIVE_TIME/10) )
                begin  //边缘蓝色
                            if(is_move==1)
                               begin
                               
                                   if(move==2'b00)//红色，向左
                                   begin
                                   Red   =  4'b1111    ;
                                   Green =  4'b0000   ;
                                   Blue  =  4'b0000    ;                    
                               
                                   end
                                   else if(move==2'b11) //黑色，向右
                                   begin
                                   Red   =  4'b0111    ;
                                   Green =  4'b0011   ;
                                   Blue  =  4'b0001    ;                    
                                                  
                                   end
                                   else if(move==2'b01)//绿色 向下
                                   begin
                                   Red   =  4'b0000    ;
                                   Green =  4'b1111   ;
                                   Blue  =  4'b0000    ;                    
                                                  
                                   end
                                   else if(move==2'b10)//蓝色，向上
                                   begin
                                   Red   =  4'b0000    ;
                                   Green =  4'b0000   ;
                                   Blue  =  4'b1111    ;                    
                                                  
                                   end
                                   else;
                               end
                               else 
                               begin
                                   Red   =  4'b1111    ;
                                   Green =  4'b1111   ;
                                   Blue  =  4'b1111    ;                    
                                                                                        
                               end                
                    //Red   =  4'b0000    ;
                    //Green =  4'b1111   ;
                    //Blue  =  4'b0000    ; 
                    
                end 


            else 
            begin

                //怎么说，就是cos和sin值的问题
                //根本存的不对

                
               //画板子（边上是圆角）

                //先画两边的球
                dis=(y_center - v_count) * cos_alpha + (x_center - h_count)* sin_alpha;
                dis2=(y_center - v_count) * sin_alpha - (x_center - h_count)* cos_alpha;               
                
                if((h_count*float_transfer - x_cir1)*(h_count*float_transfer - x_cir1) + (v_count*float_transfer - y_cir1) *(v_count*float_transfer - y_cir1) <= half_thick * half_thick*float_transfer*float_transfer )
                begin                                                  
                    Red   =  4'b1111    ;
                    Green =  4'b1111   ;
                    Blue  =  4'b1111    ;                    
                end
                else if((h_count*float_transfer - x_cir2)*(h_count*float_transfer - x_cir2) + (v_count*float_transfer - y_cir2) *(v_count*float_transfer - y_cir2) <= half_thick * half_thick*float_transfer*float_transfer )
                begin
                    Red   =  4'b1111    ;
                    Green =  4'b1111   ;
                    Blue  =  4'b1111    ;                    
                end   
                             
                             
                //else  if(h_count*float_transfer >= x_left && (h_count*float_transfer <=x_right ) && (v_count*float_transfer >= y_left ) && (v_count*float_transfer <=y_right ))
                //begin
                    //if((v_count - y_center) * cos_alpha + (h_count - x_center)* sin_alpha >0)//一开始窄线是因为cos为500

                    
                   else if((dis <= half_thick*float_transfer && dis>= -half_thick*float_transfer)&&( dis2 >= -float_transfer*length/2 && dis2 <= float_transfer*length/2))
                    begin
                                           
                        Red   =  4'b1111    ;
                        Green =  4'b1111   ;
                        Blue  =  4'b1111    ; 
                    end 
                //end
                
                
                    
                    //画球
                else if((h_count - x_ball)*(h_count - x_ball) + (v_count - y_ball)*(v_count - y_ball)<=r_ball*r_ball/*1000000*/)
                        begin

                             Red   =  4'b1111    ;
                            Green =  4'b1111   ;
                            Blue  =  4'b1111    ; 
                        end
                    
                    //其他地方
                else
                        begin
                            Red   =  4'b0000    ; // 黑色
                            Green =  4'b0000   ;
                            Blue  =  4'b0000    ;                   
                        end
             
             
                        
          
          end                       
      
   end

   end
   
   
   
    
endmodule
