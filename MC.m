function MC()

T1=xlsread('Mean_AI_age.xlsx','A2:D66');

Age = T1(:,1);
AI = T1(:,2);
SE = T1(:,3);
sampleN=length(Age);
k=0;
SX=[];
SY=[];
n=1000;

% Monte Carlo simulation

for i = 1:1:sampleN
    
    if AI(i)>0
        
        SAI=normrnd(AI(i),(SE(i)/2),1,n);
        for j = 1:n
            SAI(j) = 1595.2 - 238.7*log(SAI(j)+0.589);
        end
        
        SAge= Age(i)-50+100*normrnd(0.5,0.25,1,n);
        SX=[SX,SAge];
        SY=[SY,SAI];
        
    end
    
end

%  calculate the result

low = 3150;       % lower limit of window
high = 3250;       % upper limit of window
movestep = 50;
count=length(SX);

for j = 1:1:((low+high)/2/movestep+1)
    
    Step = j
    dataAB=[];
    BinAB=[];
    AB_mean=0;
    AB_sigma=0;
    
    for i = 1:1:count
        if SX(i) >= low & SX(i) <= high
            BinAB(i)=SY(i);
        else
            BinAB(i)=nan;
        end
    end
    
    dataAB=BinAB(~isnan(BinAB));
    n(j)=length(dataAB);
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(dataAB);       %mean
    result(j,3)=std(dataAB)*2;      %standard errors
    result(j,4)=n(j);
    
    low = low - movestep;
    high = high - movestep;
    
end

Point(:,1)=SX;
Point(:,2)=SY;

figure(1)
plot(SX,SY,'c.')

figure(2)
errorbar(result(:,1),result(:,2),result(:,3));
csvwrite('MC_Tp_point.csv',Point)
csvwrite('MC_Tp_mean.csv',result);

end