for i=1:length(x)
    s(i)=sum(Days_cure(1,[1:i]));
    s_natural(i)=sum(Days_cure_natural(1,[1:i]));
end
plot(x,s,'b')
hold on
plot(x,s_natural,'r')
hold on
legend('�����λ����','�����λ����')
xlabel('����')
ylabel('����������')