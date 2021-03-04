function [Position,work] = Pos_judge(Home_x,Home_y,Company_x,Company_y,Radius,Safe_distance,Road_distance)
% �ú��������õ�һ���˵�·��ʱ���ע�����ֱ�ӱȽ������������Ƿ����
% ceil��������ȡ����floor����ȡ��
% ��������������Ӧȷ����m���Ƶ�
% ���ص�Position��¼��һ����ÿ��ʱ϶�Ķ�λ���꣨ÿ��ʱ϶10s������һ��N�ж��е�����
%  Route_table��������ϰ��·��ʱ���,ÿ�������±����10s�Ĳ��м��
%  block_x�����λ��
%Safe_distance = 12;
%Road_distance = 100;
Radius = Radius*1000;%ת������

Block_Home_x = floor((Home_x+Radius)/Road_distance)+1;
Block_Home_y = floor((Home_y+Radius)/Road_distance)+1;

Block_Company_x = floor((Company_x+Radius)/Road_distance)+1;
Block_Company_y = floor((Company_y+Radius)/Road_distance)+1;

work=1;%����Һ͹�˾����ͬһ�������ڣ���˵�������У���ʱwork=0
%�ж��ƶ����������     ͬһ����һ��γ������ͬһ����һ����������
%1.γ������ͬ����������ͬ   ����������ͬһ�в�ͬ�У��迼������
if((Block_Home_x~=Block_Company_x)&&(Block_Home_y==Block_Company_y))
    distance = abs(Home_x-Company_x); %�г̾���
    Numbers_slot = ceil(distance/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
    Position=ones(Numbers_slot,2);
    middle_y = (Home_y+Company_y)/2;
    if(middle_y<(-Radius+((Block_Home_y-1)*Road_distance+(Road_distance/2)))) %������
        for i = 1:Numbers_slot 
            if(Company_x >=Home_x) %�˴��Ĵ��ڵ��ں���Ҫ����
                Position(i,1) = Home_x+i*Safe_distance;  %������
                Position(i,2) = -Radius+(Block_Home_y-1)*Road_distance;  %������
            end
            if(Company_x < Home_x)
                Position(i,1) = Home_x-i*Safe_distance;  %������
                Position(i,2) = -Radius+(Block_Home_y-1)*Road_distance;  %������
            end
        end
    else %������
         for i = 1:Numbers_slot 
            if(Company_x >=Home_x) %�˴��Ĵ��ڵ��ں���Ҫ����
                Position(i,1) = Home_x+i*Safe_distance;  %������
                Position(i,2) = -Radius+(Block_Home_y)*Road_distance;  %������
            end
            if(Company_x < Home_x)
                Position(i,1) = Home_x-i*Safe_distance;  %������
                Position(i,2) = -Radius+(Block_Home_y)*Road_distance;  %������
            end
        end
    end  
    
end

%2.γ������ͬ����������ͬ         ͬһ����һ��γ������ͬһ����һ����������
%  ����������ͬһ�У���ͬ�У��迼������
if((Block_Home_x==Block_Company_x)&&(Block_Home_y~=Block_Company_y))
    distance = abs(Home_y-Company_y); %�г̾���
    Numbers_slot = ceil(distance/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
    Position=ones(Numbers_slot,2);
    middle_x = (Home_x+Company_x)/2;
    if(middle_x<(-Radius+((Block_Home_x-1)*Road_distance+(Road_distance/2)))) %���������
        for i = 1:Numbers_slot 
            if(Company_y >=Home_y) %�˴��Ĵ��ڵ��ں���Ҫ����  ��˾������
                Position(i,1) = -Radius+(Block_Home_x-1)*Road_distance;  %������
                Position(i,2) = Home_y+i*Safe_distance;  %������
            end
            if(Company_y < Home_y)  %��˾������
                Position(i,1) = -Radius+(Block_Home_x-1)*Road_distance; %������
                Position(i,2) = Home_y-i*Safe_distance;  %������
            end
        end
    else  %���ұ�
        for i = 1:Numbers_slot 
            if(Company_y >=Home_y) %�˴��Ĵ��ڵ��ں���Ҫ����  ��˾������
                Position(i,1) = -Radius+(Block_Home_x)*Road_distance;  %������
                Position(i,2) = Home_y+i*Safe_distance;  %������
            end
            if(Company_y < Home_y)  %��˾������
                Position(i,1) = -Radius+(Block_Home_x)*Road_distance; %������
                Position(i,2) = Home_y-i*Safe_distance;  %������
            end
        end
    end
end

%3.γ������ͬ����������ͬ         ͬһ����һ��γ������ͬһ����һ����������
%�ڵ���������£���·����ѡ�����Ϻ����µ�·�ߣ������ߣ�Ȼ����ѡ�����ҵ�·��
if((Block_Home_x~=Block_Company_x)&&(Block_Home_y~=Block_Company_y))
    if((Block_Home_x<Block_Company_x)&&(Block_Home_y<Block_Company_y))  %��˾�����Ͻ�
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance-Road_distance)-Radius));  %��ֱ����
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Radius));     %ˮƽ����
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius;  %������
                Position(i,2) = Home_y+i*Safe_distance;  %������
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius)+(i-Numbers_slot(1))*Safe_distance;  %������
                Position(i,2) = ((Block_Company_y*Road_distance-Road_distance)-Radius);  %������
            end
        end 
    end
    if((Block_Home_x<Block_Company_x)&&(Block_Home_y>Block_Company_y))  %��˾�����½�
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance)-Radius));  %��ֱ����
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Radius));     %ˮƽ����
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius;  %������
                Position(i,2) = Home_y-i*Safe_distance;  %������
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius)+(i-Numbers_slot(1))*Safe_distance;  %������
                Position(i,2) = ((Block_Company_y*Road_distance)-Radius);  %������
            end
        end 
    end
    if((Block_Home_x>Block_Company_x)&&(Block_Home_y<Block_Company_y))  %��˾�����Ͻ�
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance-Road_distance)-Radius));  %��ֱ����
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Road_distance-Radius));     %ˮƽ����
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*100-Radius-Road_distance;  %������
                Position(i,2) = Home_y+i*Safe_distance;  %������
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius-Road_distance)-(i-Numbers_slot(1))*Safe_distance;  %������
                Position(i,2) = ((Block_Company_y*Road_distance-Road_distance)-Radius);  %������
            end
        end
    end
    if((Block_Home_x>Block_Company_x)&&(Block_Home_y>Block_Company_y))  %��˾�����½�
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance)-Radius));  %��ֱ����
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Road_distance-Radius));     %ˮƽ����
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %һ���ж��ٸ�ʱ϶��һ��ʱ϶10��,��Ӧ����12m��
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius-Road_distance;  %������
                Position(i,2) = Home_y-i*Safe_distance;  %������
            else
                Position(i,1) = (Block_Home_x*Road_distance-Road_distance-Radius)-(i-Numbers_slot(1))*Safe_distance;  %������
                Position(i,2) = ((Block_Company_y*Road_distance)-Radius);  %������
            end
        end
    end
end

%4.γ������ͬ����������ͬ         ͬһ����һ��γ������ͬһ����һ����������
if((Block_Home_x==Block_Company_x)&&(Block_Home_y==Block_Company_y))
    work=0;
    Position=[];
end
end

