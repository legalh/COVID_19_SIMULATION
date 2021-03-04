function [Home_x_m,Home_y_m] = Pos_convey(Home_x,Home_y)
%UNTITLED2 此处显示有关此函数的摘要
%   将地理坐标进行进制转换
x=Home_x*1000;
y=Home_y*1000;
Home_x_m=floor(x);
Home_y_m=floor(y);
end
