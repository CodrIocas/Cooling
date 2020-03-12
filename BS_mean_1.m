function ave()
%
T=xlsread('Georoc_basalt.xlsx','I2:AI31330');

AGE=T(:,1);
SiO2=T(:,3);
AI=T(:,22);
MgO=T(:,11);
SrY=T(:,23);
LOI=T(:,16);
Year=T(:,24);

sampleN=length(AGE);

low = 3050;       % lower limit of window
high = 3350;       % upper limit of window
movestep = 50;
sampleN=length(AGE);

for i = 1:1:sampleN
    if SiO2(i) <= 52 & SiO2(i) >=45;   %
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end
% 
for i = 1:1:sampleN
    if AI(i) >8;   %
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

% %
for i = 1:1:sampleN
    if LOI(i) >5;   %
        AI(i)=nan;
        SiO2(i)=nan;
    end
end
% %
for i = 1:1:sampleN
    if MgO(i) < 17 & MgO(i) > 0;   %
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

%
for i = 1:1:sampleN
    if Year(i) < 1980;   %
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if AGE(i) <=50;
        AI(i)=nan;
        SiO2(i)=nan;
    end
end
% %
for i = 1:1:sampleN
    if SrY(i) <25;
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end


n=[];

for j = 1:1:((low+high)/2/movestep+1)
    
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
    %
    OutlierH=quantile(BinAB(~isnan(BinAB)),0.75);
    OutlierL=quantile(BinAB(~isnan(BinAB)),0.25);
    
    for i = 1:1: sampleN;   % remove the outliers
        if BinAB(i)>OutlierH
            BinAB(i)=nan;
            SiO2(i)=nan;
        end
    end
    
    dataAB=BinAB(~isnan(BinAB));
    n(j)=length(dataAB);
    
    if n(j)>=5       % less than 3 samples will not be calculated.
        BSmean_AB = bootstrp(5000, @mean, dataAB);
    else
        BSmean_AB = [];
    end
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(BSmean_AB);       %mean
    result(j,3)=2*std(BSmean_AB);      %standard errors
    result(j,4)=n(j);
    
    low = low - movestep;
    high = high - movestep;
    
end

figure(1)
errorbar(result(:,1),result(:,2),result(:,3));

csvwrite('BS_georoc_LP_AI_300_.csv',result);

end

