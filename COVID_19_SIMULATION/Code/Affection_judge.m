function flag = Affection_judge(Position_sick,Position_normal,LENGTH,Safe_distance,Rate_Affection_status12)
%  �ú����ж���һ���׶��Ƿ��п��ܸ�Ⱦ
%  ����ֵΪ1����˵���������ѱ���Ⱦ������ֵΪ0����δ����Ⱦ��  ע�⼴ʹС�ڰ�ȫ���룬��Ҳֻ���п��ܸ�Ⱦ
%  LENGTHΪ������ʱ϶��������Сֵ��kΪ
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
    if(flag==1) %δ����Ⱦ
        flag=0;
    else  %����Ⱦ
        flag=1;
    end
else
    flag=0;
end

end

