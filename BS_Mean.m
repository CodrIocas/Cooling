function ave()
%
T=xlsread('EarthChem_vol.xlsx','I2:BP43837');

AGE=T(:,1);
SiO2=T(:,3);
AI=T(:,52);
lgAI=T(:,57);
lgLa=T(:,56);

MgO=T(:,11);

SrY=T(:,53);
Na2K=T(:,54);
LOI=T(:,16);

sampleN=length(AGE);

for i = 1:1:sampleN
    if SiO2(i) <= 55 & SiO2(i) >=45;
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

for i = 1:1:sampleN
    if MgO(i) < 17;
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if SrY(i)>25;
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

for i = 1:1:sampleN
    if Na2K(i) >1;   %
        AI(i)=AI(i);
        SiO2(i)=SiO2(i);
    else
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

lgAI_Umost = 0.5695*lgLa + 0.0809;
lgAI_Lmost= 0.4831*lgLa - 0.8609;

for i = 1:1:sampleN
    if lgAI(i) > lgAI_Umost(i) || lgAI(i) < lgAI_Lmost(i);
        AI(i)=nan;
        SiO2(i)=nan;
    end
end

low = 900;
high = 1100;
movestep = 50;

n=[];

for j = 1:1:10     % 1000-500 Ma
    
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
    
    if n>=5       % less than 5 samples will not be calculated.
        BSmean_AB = bootstrp(10000, @mean, dataAB);
    else
        BSmean_AB = [];
    end
    
    result(j,1)=(low+high)/2;    % age
    result(j,2)=mean(BSmean_AB);       % mean
    result(j,3)=2*std(BSmean_AB);      % 2 standard errors
    result(j,4)=n;
    
    
    low = low - movestep;
    high = high - movestep;
    
end

low = 400;
high = 600;
movestep = 50;

for j = 11:1:21   % 500-0 Ma
    
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
    
    if n>=5       % less than 5 samples will not be calculated.
        BSmean_AB = bootstrp(10000, @mean, dataAB);
    else
        BSmean_AB = [];
    end
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(BSmean_AB);       %mean
    result(j,3)=2*std(BSmean_AB);      %standard errors
    result(j,4)=n;
    
    result(j,1)=(low+high)/2;    %age
    result(j,2)=mean(dataAB);       %mean
    result(j,3)=2*std(dataAB)/sqrt(n);      %standard errors
    result(j,4)=n;
    
    low = low - movestep;
    high = high - movestep;
    
end

figure(3)
errorbar(result(:,1),result(:,2),result(:,3));

csvwrite('Mean_AI.csv',result);

end

