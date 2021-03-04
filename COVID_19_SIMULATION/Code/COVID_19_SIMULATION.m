function [Numbers_affection,Numbers_death,Days_affection,Days_death,Days_cure] = COVID_19_SIMULATION(~)
%% 代码简单说明   主要探究隔离和床位对疫情防控的影响
%正常人0、潜伏者1（可感染他人但可能自愈）、感染未诊断2、感染已诊断居家隔离3、感染已诊断住院4、治愈者5，死亡者6,被感染的第一天7（此时没有感染他人能力，第二天才有）
%地图为正方形，边长2.4KM，大小5.76平方公里，总人口14000，所有人采取步行的方式移动，所有人每天7：00开始出门，17：00开始回家
%地图交通情况介绍：
%正方形的地图：所有道路均为直线，每隔100米一条道路，竖的道路和横的道路将地图切割成大小为10000平方米的网格
%             划分网格后的坐标由纬度区和经度区表示
%             如果-1200<x<-1100,则处于纬度一区，向右纬度区数以100米为界限不断增加
%             同理，即左下角的网格的坐标为纬度一区，经度一区。同一列是一个纬度区，同一行是一个经度区。
%传播规则：
%通勤过程中，安全距离为12m，即人10秒走过的时间，若同一时间段出现距离小于安全距离12m，即可能感染，感染概率0.1
%在公司或家中，安全距离8m，即家的坐标或公司的坐标距离小于8m，则可能感染，感染概率0.1
%一次感染过程中，正常人只可能被感染，不可能出现被感染后立即感染他人，即被感染的人一天之内是没有感染他人的能力的
%四次传播机会：
%1.上班途中
%2.公司
%3.下班途中
%4.家
%
%
%
%
%
%
%
%
%
%
%阶段和规则介绍
%
%阶段一：新冠病毒自然传播，模拟人群流动
%对应规则：
% 1.根据轨迹和感染规则，对患者进行遍历，判断每一个患者与其他人（除患者本身外）的距离，计算新增感染人数，加入患者行列
% 2.根据患者的种类（1，2，3，4） 计算相应的潜伏天数，隔离天数，治疗天数。若天数达到要求，执行对应仿真操作
%
%阶段二：新冠病毒自然传播，模拟人群流动。出现人群大规模流动（返乡），返乡人口老龄化率10%,医护人员不返乡，其余人正常工作
%对应规则：
% 1.根据轨迹和感染规则，对患者进行遍历，判断每一个患者与其他人（除患者本身外）的距离，计算新增感染人数，加入患者行列
% 2.根据患者的种类（1，2，3，4） 计算相应的潜伏天数，隔离天数，治疗天数。若天数达到要求，执行对应仿真操作
% 
%
%
%
%
%
%
%
%
%
%
%
%
%
%% 变量设定
Period_days = [20,30,20];%三个阶段的天数分别是
Days=sum(Period_days);  %总天数
Numbers = 1400;  %总人口1.4K
%Numbers_local = 9000;   %疫情阶段留在本地的9K
%Numbers_out = 5000;    %第二阶段离开武汉的5K
Days_affection = zeros(1,Days); %每日的感染人数数组
Day_affection = 0;%每日新增感染人数
Days_death = zeros(1,Days); %每日的死亡人数数组
Day_death = 0;%每日新增死亡人数
Days_cure = zeros(1,Days); %每日的痊愈人数数组
Day_cure = 0;%每日新增痊愈人数


Numbers_doc = 30;      %医生数
Numbers_affection = 1; %最初感染人数为1
Numbers_death = 0;     %死亡总人数
Rate_Affection_status12 = 0.01; %第一、阶段感染概率0.01
Cure_days_weak = 25;       %老年人住院天数平均25天
Cure_days_strong = 10;     %青壮年住院天数平均10天
Radius = 1.2;    %正方形地图的边长是2.4KM
Safe_distance = [12,8]; %在道路上的安全距离是12M,在家里和公司的安全距离是8M
Road_distance = 100;
sigama = Radius/3;    %人口正态分布的标准差，根据正态分布的三标准差原则
%Rate_dp = 2;   %医生病患比为2，即一个医生可以照顾两个病患
%ROA_ave = [2.0,45.9,162.6,77.9,17.2]/1000000; % daily rate for confirmed  in five periods(all classes)
%ROA_HW = [5.1,272.3,617.4,159.5,21.8,130.5]/1000000; %daily rate of for confirmed in five periods(healthy workers)

%医院病床数的增加次序需要修改
for i = 1:Days  %每日医院总病床数
    if(i<=Period_days(1))
        beds_all(i) = 60;
    elseif((i>Period_days(1))&&(i<=(Period_days(1)+Period_days(2))))
        beds_all(i) = 380;
    else
        beds_all(i) = 380;
    end
end
beds_used = 0; %已经使用病床数

Rate_old = 0.23; %老龄人口占人口总数的百分比

Iso_days = [14,28];  %居家隔离的死亡时间点，第一个是14，第二个是28
Deathrate_iso_old = [0.5,0.9]; %老年人患病后居家隔离0-14天的死亡率0.08，当隔离天数到达14后“人为选择死亡对象”
                                %老年人患病后居家隔离15-28天的死亡率0.2，当隔离天数到达28后“人为选择死亡对象”
Deathrate_iso_strong = [0.1,0.2];  %青壮年患病后居家隔离0-14天的死亡率0.01，当隔离天数到达14后“人为选择死亡对象”
                                       %青壮年患病后居家隔离15-28天的死亡率0.016，当隔离天数到达28后“人为选择死亡对象”
Cure_effect = [0.1,0.25];  %居家隔离时间小于两周内住院,死亡率为对应隔离时间的0.1
                           %居家隔离时间超过两周后住院，死亡率为对应隔离时间的0.3
Rate_latent = [0.8,0.2];   %潜伏期到达后，老年人80%可能出现症状，青壮年可能20%出现症状，即不同人群从潜伏期到出现政症状的概率
Latent_days = [5,9];       %老年人的潜伏期为5天，青壮年的潜伏期为9天

HUMANS(1) = struct('ID',1,'Age',1,'SYM_AFFECTION',1,'SYM_WORK',0,'Home_x',0,'Home_y',0,'Company_x',-0.34,'Company_y',0.15,'Rt',0);
%居民信息
Patients(1) = struct('ID',1,'Age',1,'SYM_AFFECTION',1,'SYM_WORK',0,'Home_x',0,'Home_y',0,'Company_x',-0.34,'Company_y',0.15,'Rt',0,'Latent_days',1,'Iso_days',0,'Hospital_days',0);
%患者信息，新增Latent_days（已在潜伏期的天数）,Iso_days（已居家隔离的天数），Hospital_days（住院治疗天数）
%Patients数组保留所有曾经感染过的人，即使之后治愈或死亡也保留在数组中

Home_x = normrnd(0,sigama,[1 (Numbers-1)]);
Home_x = [HUMANS(1).Home_x,Home_x];
Home_y = normrnd(0,sigama,[1 (Numbers-1)]);
Home_y = [HUMANS(1).Home_y,Home_y];
Company_x = normrnd(0,sigama,[1 (Numbers-Numbers_doc-1)]);
Company_x = [HUMANS(1).Company_x,Company_x];
Company_y = normrnd(0,sigama,[1 (Numbers-Numbers_doc-1)]);
Company_y = [HUMANS(1).Company_y,Company_y];
Age = rand(1,(Numbers-Numbers_doc-1))-Rate_old;  %人口中80%是青壮年,标志位1    标志位0为老年
Age = ceil(Age);
Age = [HUMANS(1).Age,Age];

for i=(Numbers-Numbers_doc+1):Numbers
    Company_x(i) = 0.32;  %医护人员工作地点的x坐标为0.32
    Company_y(i) = 0.43;  %医护人员工作地点的y坐标为0.43
    Age(i) = 1;          %医护人员都是青壮年
end

for i=1:(Numbers-Numbers_doc-1)
    SYM_WORK(i) = 0;
end
SYM_WORK=[HUMANS(1).SYM_WORK,SYM_WORK];
for i=(Numbers-Numbers_doc+1):Numbers
    SYM_WORK(i) = 1;  %HUMANS结构数组中最后面的都是医生，医生的工作标志位都是1
end

for i=1:Numbers-1
    SYM_AFFECTION(i) = 0;
end
SYM_AFFECTION = [HUMANS(1).SYM_AFFECTION,SYM_AFFECTION];

[Home_x,Home_y]=Pos_convey(Home_x,Home_y);
[Company_x,Company_y]=Pos_convey(Company_x,Company_y); %将坐标转化为米进制

for i=1:Numbers
    HUMANS(i) =  struct('ID',i,'Age',Age(i),'SYM_AFFECTION',SYM_AFFECTION(i),'SYM_WORK',SYM_WORK(i),'Home_x',Home_x(i),'Home_y',Home_y(i),'Company_x',Company_x(i),'Company_y',Company_y(i),'Rt',0);
end
%在变量HUMANS中，坐标均是米进制的。

%获取所有人的路程信息
HUMANS_Position=ones(Numbers,400,2)*2000;
for i = 1:Numbers
    [Position,work]=Pos_judge(HUMANS(i).Home_x,HUMANS(i).Home_y,HUMANS(i).Company_x,HUMANS(i).Company_y,Radius,Safe_distance(1),Road_distance);
    if (work==1)
        LENGTH(i)=size(Position,1);  %LENGTH数组记录每个人的时隙数量
        HUMANS_Position(i,[1:LENGTH(i)],[1,2])=Position;
    else
        LENGTH(i)=0;
    end
end   
%% 病毒感染模拟
for i = 1:length(Period_days)  %i是阶段数
    switch i
        case 1  %阶段1  自然传播   计算具有感染性的人和正常人的安全距离
            for j = 1:Period_days(1)  %j是天数
                %初始化变量
                Day_affection = 0;%每日新增感染人数
                Day_death = 0;%每日新增死亡人数
                Day_cure = 0;%每日新增痊愈人数
                %上班传播
                for jj = 1:length(Patients)  %将每个患者的路径和其他人进行匹配，判断是否感染  
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0)) %说明jj对应的是可以自由行动的潜伏者且jjj对应的人是正常人
                            flag=Affection_judge(HUMANS_Position(Patients(jj).ID,:,:),HUMANS_Position(HUMANS(jjj).ID,:,:),min(LENGTH(jj),LENGTH(jjj)),Safe_distance(1),Rate_Affection_status12);
                            if (flag==1)%感染成功
                                HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj对应的人成功感染人数加一
                                Patients(jj).Rt=Patients(jj).Rt+1;        %两方面数据都进行对应修改
                                Numbers_affection = Numbers_affection+1; %总感染人数加一
                                Day_affection = Day_affection+1;%新增感染人数加一
                                HUMANS(jjj).SYM_AFFECTION = 7;
                                Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                
                            end
                        end
                    end
                end
                
            %公司传播
                for jj = 1:length(Patients)
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0))
                            distance = sqrt((Patients(jj).Company_x-HUMANS(jjj).Company_x)^2+(Patients(jj).Company_y-HUMANS(jjj).Company_y)^2);
                            if (distance<Safe_distance(2))  %可能感染
                                flag = rand(1,1);
                                flag = flag-Rate_Affection_status12;
                                flag = ceil(flag);
                                if flag==0     %确实感染
                                    HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj对应的人成功感染人数加一
                                    Patients(jj).Rt=Patients(jj).Rt+1;        %两方面数据都进行对应修改
                                    Numbers_affection=Numbers_affection+1; %总感染人数加一
                                    Day_affection = Day_affection+1;%新增感染人数加一
                                    HUMANS(jjj).SYM_AFFECTION = 7;
                                    Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                end
                            end
                        end
                    end
                end
            
            %下班传播  暂时不考虑了   
            
            %居家传播
                for jj = 1:length(Patients)
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0))
                            distance = sqrt((Patients(jj).Home_x-HUMANS(jjj).Home_x)^2+(Patients(jj).Home_y-HUMANS(jjj).Home_y)^2);
                            if (distance<Safe_distance(2))  %可能感染
                                flag = rand(1,1);
                                flag = flag-Rate_Affection_status12;
                                flag = ceil(flag);
                                if flag==0     %确实感染
                                    HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj对应的人成功感染人数加一
                                    Patients(jj).Rt=Patients(jj).Rt+1;        %两方面数据都进行对应修改
                                    Numbers_affection=Numbers_affection+1; %总感染人数加一
                                    Day_affection = Day_affection+1;%新增感染人数加一
                                    HUMANS(jjj).SYM_AFFECTION = 7;
                                    Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                end
                            end
                        end
                    end
                end
            
            %收尾工作
            %1.对所有今日新增的患者潜伏期加一天，感染状态改为1  
            for jj = 1:length(Patients)%收尾
                %1.将所有今日新增的患者转换为潜伏者，感染状态改为1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%这里是0因为下面会加一
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.判断潜伏期是否达到时间
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %青壮年
                        if(Patients(jj).Latent_days==Latent_days(2)) %达到潜伏时间，20%几率出现症状，80%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %如果是老年人
                        if(Patients(jj).Latent_days==Latent_days(1)) %达到潜伏时间，80%几率出现症状，20%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.判断居家隔离是否达到时间
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %没有空床位
                        if(Patients(jj).Age==0)%老年人
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到14天继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%总死亡人数加一
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %青壮年
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到第一隔离死亡时间点继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %有空床位
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.判断住院是否达到时间
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %如果是青壮年
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %如果是老年人
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %统计数据
            Days_affection(j) = Day_affection;%每日感染人数
            Days_death(j) = Day_death;%每日死亡人数
            Days_cure(j) = Day_cure;%每日痊愈人数
            
            end%第一阶段结束
            
            
        case 2  %阶段2
           for j = (Period_days(1)+1):(Period_days(2)+Period_days(1))  %j是天数
                %初始化变量
                Day_affection = 0;%每日新增感染人数
                Day_death = 0;%每日新增死亡人数
                Day_cure = 0;%每日新增痊愈人数
    
            %收尾工作
            %1.对所有今日新增的患者潜伏期加一天，感染状态改为1  
            for jj = 1:length(Patients)%收尾
                %1.将所有今日新增的患者转换为潜伏者，感染状态改为1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%这里是0因为下面会加一
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.判断潜伏期是否达到时间
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %青壮年
                        if(Patients(jj).Latent_days==Latent_days(2)) %达到潜伏时间，20%几率出现症状，80%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %如果是老年人
                        if(Patients(jj).Latent_days==Latent_days(1)) %达到潜伏时间，80%几率出现症状，20%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.判断居家隔离是否达到时间
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %没有空床位
                        if(Patients(jj).Age==0)%老年人
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到14天继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%总死亡人数加一
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %青壮年
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到第一隔离死亡时间点继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %有空床位
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.判断住院是否达到时间
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %如果是青壮年
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %如果是老年人
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %统计数据
            Days_affection(j) = Day_affection;%每日感染人数
            Days_death(j) = Day_death;%每日死亡人数
            Days_cure(j) = Day_cure;%每日痊愈人数
            
            end%第二阶段结束 
            
        case 3  %阶段3
            
            
            for j = (Period_days(1)+Period_days(2)+1):(Period_days(1)+Period_days(2)+Period_days(3))  %j是天数
                %初始化变量
                Day_affection = 0;%每日新增感染人数
                Day_death = 0;%每日新增死亡人数
                Day_cure = 0;%每日新增痊愈人数
    
            %收尾工作
            %1.对所有今日新增的患者潜伏期加一天，感染状态改为1  
            for jj = 1:length(Patients)%收尾
                %1.将所有今日新增的患者转换为潜伏者，感染状态改为1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%这里是0因为下面会加一
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.判断潜伏期是否达到时间
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %青壮年
                        if(Patients(jj).Latent_days==Latent_days(2)) %达到潜伏时间，20%几率出现症状，80%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %如果是老年人
                        if(Patients(jj).Latent_days==Latent_days(1)) %达到潜伏时间，80%几率出现症状，20%痊愈
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %痊愈
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %出现症状
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %有空床位
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %没有空床位，居家隔离
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %如果未达到潜伏时间,则继续潜伏
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.判断居家隔离是否达到时间
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %没有空床位
                        if(Patients(jj).Age==0)%老年人
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到14天继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%总死亡人数加一
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %青壮年
                            if(Patients(jj).Iso_days<Iso_days(1)) %不到第一隔离死亡时间点继续隔离
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %到第一个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %没死继续隔离
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%到第二个隔离死亡时间点
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %没死，获得免疫
                                    Day_cure = Day_cure+1; %新增痊愈人数加一
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %死了
                                    Day_death = Day_death+1;%当日死亡人数加一
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%在第一隔离死亡时间点和第二隔离死亡时间点之间
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %有空床位
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.判断住院是否达到时间
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %如果是青壮年
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %如果是老年人
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %不到出院时间
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %到达出院时间
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %没死，获得免疫
                                Day_cure = Day_cure+1; %新增痊愈人数加一
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %死了
                                Day_death = Day_death+1;%当日死亡人数加一
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %统计数据
            Days_affection(j) = Day_affection;%每日感染人数
            Days_death(j) = Day_death;%每日死亡人数
            Days_cure(j) = Day_cure;%每日痊愈人数
            
            end%第三阶段结束
            
        %case 4  %阶段4
            
        %case 5  %阶段5
            
    end
end


%% 绘图



%% 发送


end


% 后续工作：
% 1.目前只考虑人们工作的情况，即所有人员无随意流动意向，这是后续可以改进的地方
% 2.目前假定居家隔离均不传染，这是后续可以改进的地方
% 3.人们的轨迹预测不合理，目前采用网格直线交通，如何实现合理的地图交通轨迹预测是一个突破的点
% 4.人们的通勤时间固定，后期可以采用引入随机数
% 5.人们从家走到道路和从道路走到公司的时间都直接忽略，轨迹计算只考虑道路上的轨迹，避免了大多数的拐角计算
% 6.计算地图道路第三种情况时，可以写成代码复用的形式，将四种减少为两种
% 7 第一二阶段的下班的流动传播暂时不考虑（时间不够）
% 8 假设症状的转换过程是立刻的，即在转换的瞬间过程中不会有新的被感染者出现
% 9 假设医生的数量充足（时间不够）



