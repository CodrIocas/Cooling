function ave()
%
T=xlsread('Data S2.xlsx','I2:AL3580');

AGE=T(:,1);
SiO2=T(:,3);
LOI=T(:,16);

AI=T(:,24);
lgAI=T(:,29);
lgLa=T(:,30);

sampleN=length(AGE);

for i = 1:1:sampleN
    if SiO2(i) <= 55 && SiO2(i) >=45;   %
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if LOI(i) >5;   %
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

lgAI_Umost = 0.5194*lgLa + 0.0278;
lgAI_Lmost= 0.5048*lgLa - 0.9758;

for i = 1:1:sampleN
    if lgAI(i) > lgAI_Umost(i) || lgAI(i) < lgAI_Lmost(i);   %
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

low = 900;
high = 1100;
movestep = 50;

n=[];

for j = 1:1:21   %1000-600 Ma
    
    Step = j
    dataAB=[];
    BinAB=[];
    AB_mean=0;
    AB_sigma=0;
    
    for i = 1:1:sampleN
        if AGE(i) >= low & AGE(i) <= high
            BinAB(i)=AI(i);
        else
            BinAB(i)=nan;
        end
    end
    
    OutlierH=quantile(BinAB(~isnan(BinAB)),0.9);
    OutlierL=quantile(BinAB(~isnan(BinAB)),0.1);
    
    for i = 1:1: sampleN;
        if BinAB(i)>OutlierH | BinAB(i)<OutlierL
            BinAB(i)=nan;
            SiO2(i)=nan;
        end
    end
    
    dataAB=BinAB(~isnan(BinAB));
    n=length(dataAB);
    
    BSmean_AB = bootstrp(10000, @mean, dataAB);
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(BSmean_AB);       %mean
    result(j,3)=2*std(BSmean_AB);      %standard errors
    result(j,4)=n;
    
    low = low - movestep;
    high = high - movestep;
    
end
%

figure(1)
errorbar(result(:,1),result(:,2),result(:,3));

csvwrite('BS_mean_AI.csv',result);

end

