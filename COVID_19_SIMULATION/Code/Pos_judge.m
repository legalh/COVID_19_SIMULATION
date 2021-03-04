function [Position,work] = Pos_judge(Home_x,Home_y,Company_x,Company_y,Radius,Safe_distance,Road_distance)
% 该函数用来得到一个人的路程时间表，注意避免直接比较两个浮点数是否相等
% ceil函数向上取整，floor向下取整
% 这里的输入参数均应确保是m进制的
% 返回的Position记录了一个人每个时隙的二位坐标（每个时隙10s），是一个N行二列的数组
%  Route_table是这个人上班的路程时间表,每个数组下标代表10s的步行间隔
%  block_x计算的位数
%Safe_distance = 12;
%Road_distance = 100;
Radius = Radius*1000;%转换进制

Block_Home_x = floor((Home_x+Radius)/Road_distance)+1;
Block_Home_y = floor((Home_y+Radius)/Road_distance)+1;

Block_Company_x = floor((Company_x+Radius)/Road_distance)+1;
Block_Company_y = floor((Company_y+Radius)/Road_distance)+1;

work=1;%如果家和公司都在同一个区域内，则说明不出行，此时work=0
%判断移动的四种情况     同一列是一个纬度区，同一行是一个经度区。
%1.纬度区不同，经度区相同   两个区域在同一行不同列，需考虑左右
if((Block_Home_x~=Block_Company_x)&&(Block_Home_y==Block_Company_y))
    distance = abs(Home_x-Company_x); %行程距离
    Numbers_slot = ceil(distance/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
    Position=ones(Numbers_slot,2);
    middle_y = (Home_y+Company_y)/2;
    if(middle_y<(-Radius+((Block_Home_y-1)*Road_distance+(Road_distance/2)))) %走下面
        for i = 1:Numbers_slot 
            if(Company_x >=Home_x) %此处的大于等于号需要考虑
                Position(i,1) = Home_x+i*Safe_distance;  %横坐标
                Position(i,2) = -Radius+(Block_Home_y-1)*Road_distance;  %纵坐标
            end
            if(Company_x < Home_x)
                Position(i,1) = Home_x-i*Safe_distance;  %横坐标
                Position(i,2) = -Radius+(Block_Home_y-1)*Road_distance;  %纵坐标
            end
        end
    else %走上面
         for i = 1:Numbers_slot 
            if(Company_x >=Home_x) %此处的大于等于号需要考虑
                Position(i,1) = Home_x+i*Safe_distance;  %横坐标
                Position(i,2) = -Radius+(Block_Home_y)*Road_distance;  %纵坐标
            end
            if(Company_x < Home_x)
                Position(i,1) = Home_x-i*Safe_distance;  %横坐标
                Position(i,2) = -Radius+(Block_Home_y)*Road_distance;  %纵坐标
            end
        end
    end  
    
end

%2.纬度区相同，经度区不同         同一列是一个纬度区，同一行是一个经度区。
%  两个区域在同一列，不同行，需考虑上下
if((Block_Home_x==Block_Company_x)&&(Block_Home_y~=Block_Company_y))
    distance = abs(Home_y-Company_y); %行程距离
    Numbers_slot = ceil(distance/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
    Position=ones(Numbers_slot,2);
    middle_x = (Home_x+Company_x)/2;
    if(middle_x<(-Radius+((Block_Home_x-1)*Road_distance+(Road_distance/2)))) %决定走左边
        for i = 1:Numbers_slot 
            if(Company_y >=Home_y) %此处的大于等于号需要考虑  公司在上面
                Position(i,1) = -Radius+(Block_Home_x-1)*Road_distance;  %横坐标
                Position(i,2) = Home_y+i*Safe_distance;  %纵坐标
            end
            if(Company_y < Home_y)  %公司在下面
                Position(i,1) = -Radius+(Block_Home_x-1)*Road_distance; %横坐标
                Position(i,2) = Home_y-i*Safe_distance;  %纵坐标
            end
        end
    else  %走右边
        for i = 1:Numbers_slot 
            if(Company_y >=Home_y) %此处的大于等于号需要考虑  公司在上面
                Position(i,1) = -Radius+(Block_Home_x)*Road_distance;  %横坐标
                Position(i,2) = Home_y+i*Safe_distance;  %纵坐标
            end
            if(Company_y < Home_y)  %公司在下面
                Position(i,1) = -Radius+(Block_Home_x)*Road_distance; %横坐标
                Position(i,2) = Home_y-i*Safe_distance;  %纵坐标
            end
        end
    end
end

%3.纬度区不同，经度区不同         同一列是一个纬度区，同一行是一个经度区。
%在第三种情况下，道路优先选择向上和向下的路线，即经线，然后再选择左右的路线
if((Block_Home_x~=Block_Company_x)&&(Block_Home_y~=Block_Company_y))
    if((Block_Home_x<Block_Company_x)&&(Block_Home_y<Block_Company_y))  %公司在右上角
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance-Road_distance)-Radius));  %垂直距离
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Radius));     %水平距离
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius;  %横坐标
                Position(i,2) = Home_y+i*Safe_distance;  %纵坐标
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius)+(i-Numbers_slot(1))*Safe_distance;  %横坐标
                Position(i,2) = ((Block_Company_y*Road_distance-Road_distance)-Radius);  %纵坐标
            end
        end 
    end
    if((Block_Home_x<Block_Company_x)&&(Block_Home_y>Block_Company_y))  %公司在右下角
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance)-Radius));  %垂直距离
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Radius));     %水平距离
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius;  %横坐标
                Position(i,2) = Home_y-i*Safe_distance;  %纵坐标
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius)+(i-Numbers_slot(1))*Safe_distance;  %横坐标
                Position(i,2) = ((Block_Company_y*Road_distance)-Radius);  %纵坐标
            end
        end 
    end
    if((Block_Home_x>Block_Company_x)&&(Block_Home_y<Block_Company_y))  %公司在左上角
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance-Road_distance)-Radius));  %垂直距离
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Road_distance-Radius));     %水平距离
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*100-Radius-Road_distance;  %横坐标
                Position(i,2) = Home_y+i*Safe_distance;  %纵坐标
            else
                Position(i,1) = (Block_Home_x*Road_distance-Radius-Road_distance)-(i-Numbers_slot(1))*Safe_distance;  %横坐标
                Position(i,2) = ((Block_Company_y*Road_distance-Road_distance)-Radius);  %纵坐标
            end
        end
    end
    if((Block_Home_x>Block_Company_x)&&(Block_Home_y>Block_Company_y))  %公司在左下角
        distance(1)=abs(Home_y-((Block_Company_y*Road_distance)-Radius));  %垂直距离
        distance(2)=abs(Company_x-(Block_Home_x*Road_distance-Road_distance-Radius));     %水平距离
        Numbers_slot(1) = ceil(distance(1)/Safe_distance);  %一共有多少个时隙（一个时隙10秒,对应距离12m）
        Numbers_slot(2) = ceil(distance(2)/Safe_distance);
        Position=ones(Numbers_slot(1)+Numbers_slot(2),2);
        for i = 1:(Numbers_slot(1)+Numbers_slot(2))
            if(i>=1&&i<=Numbers_slot(1))
                Position(i,1) = Block_Home_x*Road_distance-Radius-Road_distance;  %横坐标
                Position(i,2) = Home_y-i*Safe_distance;  %纵坐标
            else
                Position(i,1) = (Block_Home_x*Road_distance-Road_distance-Radius)-(i-Numbers_slot(1))*Safe_distance;  %横坐标
                Position(i,2) = ((Block_Company_y*Road_distance)-Radius);  %纵坐标
            end
        end
    end
end

%4.纬度区相同，经度区相同         同一列是一个纬度区，同一行是一个经度区。
if((Block_Home_x==Block_Company_x)&&(Block_Home_y==Block_Company_y))
    work=0;
    Position=[];
end
end

