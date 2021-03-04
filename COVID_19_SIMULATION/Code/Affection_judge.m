function flag = Affection_judge(Position_sick,Position_normal,LENGTH,Safe_distance,Rate_Affection_status12)
%  该函数判断在一二阶段是否有可能感染
%  返回值为1，则说明正常人已被感染，返回值为0，则未被感染。  注意即使小于安全距离，但也只是有可能感染
%  LENGTH为两个人时隙数量的最小值，k为
distance = 100;
for i=1:LENGTH
    distance = sqrt((Position_sick(1,i,1)-Position_normal(1,i,1))^2+(Position_sick(1,i,2)-Position_normal(1,i,2))^2);
    if (distance < Safe_distance)
        break;
    end
end

if(distance < Safe_distance)
    flag = rand(1,1);
    flag = flag-Rate_Affection_status12;
    flag = ceil(flag);
    if(flag==1) %未被感染
        flag=0;
    else  %被感染
        flag=1;
    end
else
    flag=0;
end

end

