function [Numbers_affection,Numbers_death,Days_affection,Days_death,Days_cure] = COVID_19_SIMULATION(~)
%% �����˵��   ��Ҫ̽������ʹ�λ��������ص�Ӱ��
%������0��Ǳ����1���ɸ�Ⱦ���˵���������������Ⱦδ���2����Ⱦ����ϾӼҸ���3����Ⱦ�����סԺ4��������5��������6,����Ⱦ�ĵ�һ��7����ʱû�и�Ⱦ�����������ڶ�����У�
%��ͼΪ�����Σ��߳�2.4KM����С5.76ƽ��������˿�14000�������˲�ȡ���еķ�ʽ�ƶ���������ÿ��7��00��ʼ���ţ�17��00��ʼ�ؼ�
%��ͼ��ͨ������ܣ�
%�����εĵ�ͼ�����е�·��Ϊֱ�ߣ�ÿ��100��һ����·�����ĵ�·�ͺ�ĵ�·����ͼ�и�ɴ�СΪ10000ƽ���׵�����
%             ����������������γ�����;�������ʾ
%             ���-1200<x<-1100,����γ��һ��������γ��������100��Ϊ���޲�������
%             ͬ�������½ǵ����������Ϊγ��һ��������һ����ͬһ����һ��γ������ͬһ����һ����������
%��������
%ͨ�ڹ����У���ȫ����Ϊ12m������10���߹���ʱ�䣬��ͬһʱ��γ��־���С�ڰ�ȫ����12m�������ܸ�Ⱦ����Ⱦ����0.1
%�ڹ�˾����У���ȫ����8m�����ҵ������˾���������С��8m������ܸ�Ⱦ����Ⱦ����0.1
%һ�θ�Ⱦ�����У�������ֻ���ܱ���Ⱦ�������ܳ��ֱ���Ⱦ��������Ⱦ���ˣ�������Ⱦ����һ��֮����û�и�Ⱦ���˵�������
%�Ĵδ������᣺
%1.�ϰ�;��
%2.��˾
%3.�°�;��
%4.��
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
%�׶κ͹������
%
%�׶�һ���¹ڲ�����Ȼ������ģ����Ⱥ����
%��Ӧ����
% 1.���ݹ켣�͸�Ⱦ���򣬶Ի��߽��б������ж�ÿһ�������������ˣ������߱����⣩�ľ��룬����������Ⱦ���������뻼������
% 2.���ݻ��ߵ����ࣨ1��2��3��4�� ������Ӧ��Ǳ�����������������������������������ﵽҪ��ִ�ж�Ӧ�������
%
%�׶ζ����¹ڲ�����Ȼ������ģ����Ⱥ������������Ⱥ���ģ���������磩�������˿����仯��10%,ҽ����Ա�����磬��������������
%��Ӧ����
% 1.���ݹ켣�͸�Ⱦ���򣬶Ի��߽��б������ж�ÿһ�������������ˣ������߱����⣩�ľ��룬����������Ⱦ���������뻼������
% 2.���ݻ��ߵ����ࣨ1��2��3��4�� ������Ӧ��Ǳ�����������������������������������ﵽҪ��ִ�ж�Ӧ�������
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
%% �����趨
Period_days = [20,30,20];%�����׶ε������ֱ���
Days=sum(Period_days);  %������
Numbers = 1400;  %���˿�1.4K
%Numbers_local = 9000;   %����׶����ڱ��ص�9K
%Numbers_out = 5000;    %�ڶ��׶��뿪�人��5K
Days_affection = zeros(1,Days); %ÿ�յĸ�Ⱦ��������
Day_affection = 0;%ÿ��������Ⱦ����
Days_death = zeros(1,Days); %ÿ�յ�������������
Day_death = 0;%ÿ��������������
Days_cure = zeros(1,Days); %ÿ�յ�Ȭ����������
Day_cure = 0;%ÿ������Ȭ������


Numbers_doc = 30;      %ҽ����
Numbers_affection = 1; %�����Ⱦ����Ϊ1
Numbers_death = 0;     %����������
Rate_Affection_status12 = 0.01; %��һ���׶θ�Ⱦ����0.01
Cure_days_weak = 25;       %������סԺ����ƽ��25��
Cure_days_strong = 10;     %��׳��סԺ����ƽ��10��
Radius = 1.2;    %�����ε�ͼ�ı߳���2.4KM
Safe_distance = [12,8]; %�ڵ�·�ϵİ�ȫ������12M,�ڼ���͹�˾�İ�ȫ������8M
Road_distance = 100;
sigama = Radius/3;    %�˿���̬�ֲ��ı�׼�������̬�ֲ�������׼��ԭ��
%Rate_dp = 2;   %ҽ��������Ϊ2����һ��ҽ�������չ���������
%ROA_ave = [2.0,45.9,162.6,77.9,17.2]/1000000; % daily rate for confirmed  in five periods(all classes)
%ROA_HW = [5.1,272.3,617.4,159.5,21.8,130.5]/1000000; %daily rate of for confirmed in five periods(healthy workers)

%ҽԺ�����������Ӵ�����Ҫ�޸�
for i = 1:Days  %ÿ��ҽԺ�ܲ�����
    if(i<=Period_days(1))
        beds_all(i) = 60;
    elseif((i>Period_days(1))&&(i<=(Period_days(1)+Period_days(2))))
        beds_all(i) = 380;
    else
        beds_all(i) = 380;
    end
end
beds_used = 0; %�Ѿ�ʹ�ò�����

Rate_old = 0.23; %�����˿�ռ�˿������İٷֱ�

Iso_days = [14,28];  %�ӼҸ��������ʱ��㣬��һ����14���ڶ�����28
Deathrate_iso_old = [0.5,0.9]; %�����˻�����ӼҸ���0-14���������0.08����������������14����Ϊѡ����������
                                %�����˻�����ӼҸ���15-28���������0.2����������������28����Ϊѡ����������
Deathrate_iso_strong = [0.1,0.2];  %��׳�껼����ӼҸ���0-14���������0.01����������������14����Ϊѡ����������
                                       %��׳�껼����ӼҸ���15-28���������0.016����������������28����Ϊѡ����������
Cure_effect = [0.1,0.25];  %�ӼҸ���ʱ��С��������סԺ,������Ϊ��Ӧ����ʱ���0.1
                           %�ӼҸ���ʱ�䳬�����ܺ�סԺ��������Ϊ��Ӧ����ʱ���0.3
Rate_latent = [0.8,0.2];   %Ǳ���ڵ����������80%���ܳ���֢״����׳�����20%����֢״������ͬ��Ⱥ��Ǳ���ڵ�������֢״�ĸ���
Latent_days = [5,9];       %�����˵�Ǳ����Ϊ5�죬��׳���Ǳ����Ϊ9��

HUMANS(1) = struct('ID',1,'Age',1,'SYM_AFFECTION',1,'SYM_WORK',0,'Home_x',0,'Home_y',0,'Company_x',-0.34,'Company_y',0.15,'Rt',0);
%������Ϣ
Patients(1) = struct('ID',1,'Age',1,'SYM_AFFECTION',1,'SYM_WORK',0,'Home_x',0,'Home_y',0,'Company_x',-0.34,'Company_y',0.15,'Rt',0,'Latent_days',1,'Iso_days',0,'Hospital_days',0);
%������Ϣ������Latent_days������Ǳ���ڵ�������,Iso_days���ѾӼҸ������������Hospital_days��סԺ����������
%Patients���鱣������������Ⱦ�����ˣ���ʹ֮������������Ҳ������������

Home_x = normrnd(0,sigama,[1 (Numbers-1)]);
Home_x = [HUMANS(1).Home_x,Home_x];
Home_y = normrnd(0,sigama,[1 (Numbers-1)]);
Home_y = [HUMANS(1).Home_y,Home_y];
Company_x = normrnd(0,sigama,[1 (Numbers-Numbers_doc-1)]);
Company_x = [HUMANS(1).Company_x,Company_x];
Company_y = normrnd(0,sigama,[1 (Numbers-Numbers_doc-1)]);
Company_y = [HUMANS(1).Company_y,Company_y];
Age = rand(1,(Numbers-Numbers_doc-1))-Rate_old;  %�˿���80%����׳��,��־λ1    ��־λ0Ϊ����
Age = ceil(Age);
Age = [HUMANS(1).Age,Age];

for i=(Numbers-Numbers_doc+1):Numbers
    Company_x(i) = 0.32;  %ҽ����Ա�����ص��x����Ϊ0.32
    Company_y(i) = 0.43;  %ҽ����Ա�����ص��y����Ϊ0.43
    Age(i) = 1;          %ҽ����Ա������׳��
end

for i=1:(Numbers-Numbers_doc-1)
    SYM_WORK(i) = 0;
end
SYM_WORK=[HUMANS(1).SYM_WORK,SYM_WORK];
for i=(Numbers-Numbers_doc+1):Numbers
    SYM_WORK(i) = 1;  %HUMANS�ṹ�����������Ķ���ҽ����ҽ���Ĺ�����־λ����1
end

for i=1:Numbers-1
    SYM_AFFECTION(i) = 0;
end
SYM_AFFECTION = [HUMANS(1).SYM_AFFECTION,SYM_AFFECTION];

[Home_x,Home_y]=Pos_convey(Home_x,Home_y);
[Company_x,Company_y]=Pos_convey(Company_x,Company_y); %������ת��Ϊ�׽���

for i=1:Numbers
    HUMANS(i) =  struct('ID',i,'Age',Age(i),'SYM_AFFECTION',SYM_AFFECTION(i),'SYM_WORK',SYM_WORK(i),'Home_x',Home_x(i),'Home_y',Home_y(i),'Company_x',Company_x(i),'Company_y',Company_y(i),'Rt',0);
end
%�ڱ���HUMANS�У���������׽��Ƶġ�

%��ȡ�����˵�·����Ϣ
HUMANS_Position=ones(Numbers,400,2)*2000;
for i = 1:Numbers
    [Position,work]=Pos_judge(HUMANS(i).Home_x,HUMANS(i).Home_y,HUMANS(i).Company_x,HUMANS(i).Company_y,Radius,Safe_distance(1),Road_distance);
    if (work==1)
        LENGTH(i)=size(Position,1);  %LENGTH�����¼ÿ���˵�ʱ϶����
        HUMANS_Position(i,[1:LENGTH(i)],[1,2])=Position;
    else
        LENGTH(i)=0;
    end
end   
%% ������Ⱦģ��
for i = 1:length(Period_days)  %i�ǽ׶���
    switch i
        case 1  %�׶�1  ��Ȼ����   ������и�Ⱦ�Ե��˺������˵İ�ȫ����
            for j = 1:Period_days(1)  %j������
                %��ʼ������
                Day_affection = 0;%ÿ��������Ⱦ����
                Day_death = 0;%ÿ��������������
                Day_cure = 0;%ÿ������Ȭ������
                %�ϰഫ��
                for jj = 1:length(Patients)  %��ÿ�����ߵ�·���������˽���ƥ�䣬�ж��Ƿ��Ⱦ  
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0)) %˵��jj��Ӧ���ǿ��������ж���Ǳ������jjj��Ӧ������������
                            flag=Affection_judge(HUMANS_Position(Patients(jj).ID,:,:),HUMANS_Position(HUMANS(jjj).ID,:,:),min(LENGTH(jj),LENGTH(jjj)),Safe_distance(1),Rate_Affection_status12);
                            if (flag==1)%��Ⱦ�ɹ�
                                HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj��Ӧ���˳ɹ���Ⱦ������һ
                                Patients(jj).Rt=Patients(jj).Rt+1;        %���������ݶ����ж�Ӧ�޸�
                                Numbers_affection = Numbers_affection+1; %�ܸ�Ⱦ������һ
                                Day_affection = Day_affection+1;%������Ⱦ������һ
                                HUMANS(jjj).SYM_AFFECTION = 7;
                                Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                
                            end
                        end
                    end
                end
                
            %��˾����
                for jj = 1:length(Patients)
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0))
                            distance = sqrt((Patients(jj).Company_x-HUMANS(jjj).Company_x)^2+(Patients(jj).Company_y-HUMANS(jjj).Company_y)^2);
                            if (distance<Safe_distance(2))  %���ܸ�Ⱦ
                                flag = rand(1,1);
                                flag = flag-Rate_Affection_status12;
                                flag = ceil(flag);
                                if flag==0     %ȷʵ��Ⱦ
                                    HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj��Ӧ���˳ɹ���Ⱦ������һ
                                    Patients(jj).Rt=Patients(jj).Rt+1;        %���������ݶ����ж�Ӧ�޸�
                                    Numbers_affection=Numbers_affection+1; %�ܸ�Ⱦ������һ
                                    Day_affection = Day_affection+1;%������Ⱦ������һ
                                    HUMANS(jjj).SYM_AFFECTION = 7;
                                    Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                end
                            end
                        end
                    end
                end
            
            %�°ഫ��  ��ʱ��������   
            
            %�ӼҴ���
                for jj = 1:length(Patients)
                    for jjj = 1:Numbers
                        if((Patients(jj).SYM_AFFECTION==1)&&(HUMANS(jjj).SYM_AFFECTION==0))
                            distance = sqrt((Patients(jj).Home_x-HUMANS(jjj).Home_x)^2+(Patients(jj).Home_y-HUMANS(jjj).Home_y)^2);
                            if (distance<Safe_distance(2))  %���ܸ�Ⱦ
                                flag = rand(1,1);
                                flag = flag-Rate_Affection_status12;
                                flag = ceil(flag);
                                if flag==0     %ȷʵ��Ⱦ
                                    HUMANS(Patients(jj).ID).Rt = HUMANS(Patients(jj).ID).Rt+1;%jj��Ӧ���˳ɹ���Ⱦ������һ
                                    Patients(jj).Rt=Patients(jj).Rt+1;        %���������ݶ����ж�Ӧ�޸�
                                    Numbers_affection=Numbers_affection+1; %�ܸ�Ⱦ������һ
                                    Day_affection = Day_affection+1;%������Ⱦ������һ
                                    HUMANS(jjj).SYM_AFFECTION = 7;
                                    Patients(Numbers_affection) = struct('ID',jjj,'Age',HUMANS(jjj).Age,'SYM_AFFECTION',7,'SYM_WORK',HUMANS(jjj).SYM_WORK,'Home_x',HUMANS(jjj).Home_x,'Home_y',HUMANS(jjj).Home_y,'Company_x',HUMANS(jjj).Company_x,'Company_y',HUMANS(jjj).Company_y,'Rt',0,'Latent_days',0,'Iso_days',0,'Hospital_days',0);
                                end
                            end
                        end
                    end
                end
            
            %��β����
            %1.�����н��������Ļ���Ǳ���ڼ�һ�죬��Ⱦ״̬��Ϊ1  
            for jj = 1:length(Patients)%��β
                %1.�����н��������Ļ���ת��ΪǱ���ߣ���Ⱦ״̬��Ϊ1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%������0��Ϊ������һ
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.�ж�Ǳ�����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %��׳��
                        if(Patients(jj).Latent_days==Latent_days(2)) %�ﵽǱ��ʱ�䣬20%���ʳ���֢״��80%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %�����������
                        if(Patients(jj).Latent_days==Latent_days(1)) %�ﵽǱ��ʱ�䣬80%���ʳ���֢״��20%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.�жϾӼҸ����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %û�пմ�λ
                        if(Patients(jj).Age==0)%������
                            if(Patients(jj).Iso_days<Iso_days(1)) %����14���������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%������������һ
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %��׳��
                            if(Patients(jj).Iso_days<Iso_days(1)) %������һ��������ʱ����������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %�пմ�λ
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.�ж�סԺ�Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %�������׳��
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %�����������
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %ͳ������
            Days_affection(j) = Day_affection;%ÿ�ո�Ⱦ����
            Days_death(j) = Day_death;%ÿ����������
            Days_cure(j) = Day_cure;%ÿ��Ȭ������
            
            end%��һ�׶ν���
            
            
        case 2  %�׶�2
           for j = (Period_days(1)+1):(Period_days(2)+Period_days(1))  %j������
                %��ʼ������
                Day_affection = 0;%ÿ��������Ⱦ����
                Day_death = 0;%ÿ��������������
                Day_cure = 0;%ÿ������Ȭ������
    
            %��β����
            %1.�����н��������Ļ���Ǳ���ڼ�һ�죬��Ⱦ״̬��Ϊ1  
            for jj = 1:length(Patients)%��β
                %1.�����н��������Ļ���ת��ΪǱ���ߣ���Ⱦ״̬��Ϊ1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%������0��Ϊ������һ
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.�ж�Ǳ�����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %��׳��
                        if(Patients(jj).Latent_days==Latent_days(2)) %�ﵽǱ��ʱ�䣬20%���ʳ���֢״��80%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %�����������
                        if(Patients(jj).Latent_days==Latent_days(1)) %�ﵽǱ��ʱ�䣬80%���ʳ���֢״��20%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.�жϾӼҸ����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %û�пմ�λ
                        if(Patients(jj).Age==0)%������
                            if(Patients(jj).Iso_days<Iso_days(1)) %����14���������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%������������һ
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %��׳��
                            if(Patients(jj).Iso_days<Iso_days(1)) %������һ��������ʱ����������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %�пմ�λ
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.�ж�סԺ�Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %�������׳��
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %�����������
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %ͳ������
            Days_affection(j) = Day_affection;%ÿ�ո�Ⱦ����
            Days_death(j) = Day_death;%ÿ����������
            Days_cure(j) = Day_cure;%ÿ��Ȭ������
            
            end%�ڶ��׶ν��� 
            
        case 3  %�׶�3
            
            
            for j = (Period_days(1)+Period_days(2)+1):(Period_days(1)+Period_days(2)+Period_days(3))  %j������
                %��ʼ������
                Day_affection = 0;%ÿ��������Ⱦ����
                Day_death = 0;%ÿ��������������
                Day_cure = 0;%ÿ������Ȭ������
    
            %��β����
            %1.�����н��������Ļ���Ǳ���ڼ�һ�죬��Ⱦ״̬��Ϊ1  
            for jj = 1:length(Patients)%��β
                %1.�����н��������Ļ���ת��ΪǱ���ߣ���Ⱦ״̬��Ϊ1
                if(Patients(jj).SYM_AFFECTION==7)
                    Patients(jj).SYM_AFFECTION = 1;
                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                    Patients(jj).Latent_days = 0;%������0��Ϊ������һ
                    %HUMANS(Patients(jj).ID).SYM_AFFECTION = 1;
                end
                %2.�ж�Ǳ�����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==1)
                    if(Patients(jj).Age==1) %��׳��
                        if(Patients(jj).Latent_days==Latent_days(2)) %�ﵽǱ��ʱ�䣬20%���ʳ���֢״��80%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(2);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else  %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else  %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1; 
                        end
                    else  %�����������
                        if(Patients(jj).Latent_days==Latent_days(1)) %�ﵽǱ��ʱ�䣬80%���ʳ���֢״��20%Ȭ��
                            flag = rand(1,1);
                            flag = flag-Rate_latent(1);
                            flag = ceil(flag);
                            if(flag==1) %Ȭ��
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����֢״
                                Patients(jj).SYM_AFFECTION = 2;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 2;
                                if(beds_used<beds_all(j))  %�пմ�λ
                                    Patients(jj).SYM_AFFECTION = 4;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                                    beds_used = beds_used+1;
                                else %û�пմ�λ���ӼҸ���
                                    Patients(jj).SYM_AFFECTION = 3;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 3;
                                end
                            end
                        else %���δ�ﵽǱ��ʱ��,�����Ǳ��
                            Patients(jj).Latent_days = Patients(jj).Latent_days+1;
                        end
                    end
                end
                %3.�жϾӼҸ����Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==3)
                    if(beds_used==beds_all(j))  %û�пմ�λ
                        if(Patients(jj).Age==0)%������
                            if(Patients(jj).Iso_days<Iso_days(1)) %����14���������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;%������������һ
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_old(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        else %��׳��
                            if(Patients(jj).Iso_days<Iso_days(1)) %������һ��������ʱ����������
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            elseif (Patients(jj).Iso_days==Iso_days(1)) %����һ����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(1);
                                flag = ceil(flag);
                                if(flag==1) %û����������
                                    Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                                else %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            elseif (Patients(jj).Iso_days==Iso_days(2))%���ڶ�����������ʱ���
                                flag = rand(1,1);
                                flag = flag-Deathrate_iso_strong(2);
                                flag = ceil(flag);
                                if(flag==1) %û�����������
                                    Day_cure = Day_cure+1; %����Ȭ��������һ
                                    Patients(jj).SYM_AFFECTION = 5;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                                else  %����
                                    Day_death = Day_death+1;%��������������һ
                                    Patients(jj).SYM_AFFECTION = 6;
                                    HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                    Numbers_death = Numbers_death+1;
                                end
                            else%�ڵ�һ��������ʱ���͵ڶ���������ʱ���֮��
                                Patients(jj).Iso_days = Patients(jj).Iso_days+1;
                            end
                        end
                        
                    else %�пմ�λ
                        Patients(jj).SYM_AFFECTION = 4;
                        HUMANS(Patients(jj).ID).SYM_AFFECTION = 4;
                        beds_used = beds_used+1;
                    end
                end
                
                %4.�ж�סԺ�Ƿ�ﵽʱ��
                if(Patients(jj).SYM_AFFECTION==4)
                    if(Patients(jj).Age==1) %�������׳��
                        if(Patients(jj).Hospital_days<Cure_days_strong)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_strong(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death =Numbers_death+1;
                            end
                        end
                    else %�����������
                        if(Patients(jj).Hospital_days<Cure_days_weak)  %������Ժʱ��
                            Patients(jj).Hospital_days = Patients(jj).Hospital_days+1;
                        else  %�����Ժʱ��
                            beds_used = beds_used-1;
                            if(Patients(jj).Iso_days<=Iso_days(1))
                                k=1;
                            else
                                k=2;
                            end
                            flag = rand(1,1);
                            flag = flag-Deathrate_iso_old(k)*Cure_effect(k);
                            flag = ceil(flag);
                            if(flag==1) %û�����������
                                Day_cure = Day_cure+1; %����Ȭ��������һ
                                Patients(jj).SYM_AFFECTION = 5;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 5;
                            else  %����
                                Day_death = Day_death+1;%��������������һ
                                Patients(jj).SYM_AFFECTION = 6;
                                HUMANS(Patients(jj).ID).SYM_AFFECTION = 6;
                                Numbers_death = Numbers_death+1;
                            end
                        end
                    end
                end
                
                
            end
            %ͳ������
            Days_affection(j) = Day_affection;%ÿ�ո�Ⱦ����
            Days_death(j) = Day_death;%ÿ����������
            Days_cure(j) = Day_cure;%ÿ��Ȭ������
            
            end%�����׶ν���
            
        %case 4  %�׶�4
            
        %case 5  %�׶�5
            
    end
end


%% ��ͼ



%% ����


end


% ����������
% 1.Ŀǰֻ�������ǹ������������������Ա�����������������Ǻ������ԸĽ��ĵط�
% 2.Ŀǰ�ٶ��ӼҸ��������Ⱦ�����Ǻ������ԸĽ��ĵط�
% 3.���ǵĹ켣Ԥ�ⲻ����Ŀǰ��������ֱ�߽�ͨ�����ʵ�ֺ���ĵ�ͼ��ͨ�켣Ԥ����һ��ͻ�Ƶĵ�
% 4.���ǵ�ͨ��ʱ��̶������ڿ��Բ������������
% 5.���ǴӼ��ߵ���·�ʹӵ�·�ߵ���˾��ʱ�䶼ֱ�Ӻ��ԣ��켣����ֻ���ǵ�·�ϵĹ켣�������˴�����ĹսǼ���
% 6.�����ͼ��·���������ʱ������д�ɴ��븴�õ���ʽ�������ּ���Ϊ����
% 7 ��һ���׶ε��°������������ʱ�����ǣ�ʱ�䲻����
% 8 ����֢״��ת�����������̵ģ�����ת����˲������в������µı���Ⱦ�߳���
% 9 ����ҽ�����������㣨ʱ�䲻����



