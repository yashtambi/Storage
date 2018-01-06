function [PDresyR1, PDresyM1, EDyearR1] = FUNdemandRESPONSE(Psupply,Pdemand,DRe)

%% Time
tpd = 96;
td = 365;
tpy = td*tpd;

%PsupplyM
PsupplyM = zeros(365,96);
for i = 1:365
    for j = 1:96
        PsupplyM(i,j) = Psupply(j+((i-1)*96));
    end
end

%PdemandM
PdemandM = zeros(365,96);
for i = 1:365
    for j = 1:96
        PdemandM(i,j) = Pdemand(j+((i-1)*96));
    end
end


%% Calculate difference
Pexcess  = zeros(1,td*tpd);
Pdeficit = zeros(1,td*tpd);

for i = 1:365
    for j = 1:96
        if PdemandM(i,j) < PsupplyM(i,j)
            Pexcess((i-1)*96+j)  = PsupplyM(i,j)-PdemandM(i,j);
        else
            Pdeficit((i-1)*96+j) = PdemandM(i,j) - PsupplyM(i,j);
        end
    end
end

%% Demand response
Edb  = zeros(1,td*tpd);
PtoDB= zeros(1,td*tpd);
PfrDB= zeros(1,td*tpd);
DRd = DRe + 0.05;

for i = 2:35040

    PtoDB(i) = DRe*Pdeficit(i);
    Edb(i) = Edb(i-1) + (PtoDB(i) * 0.25);
        if Edb(i) > DRd*Pexcess(i) && Pexcess(i) > 0
            PfrDB(i) = DRd*Pexcess(i);
            Edb(i) = Edb(i-1) - (PfrDB(i) * 0.25);
        end
end
    
%% apply demand respose
PDresyR1 = Pdemand + PfrDB - PtoDB;
    
%% Create year matrix
PDresyM1 = zeros(365,96);
for i = 1:365
    for j = 1:96
        PDresyM1(i,j) = PDresyR1(j+((i-1)*96));
    end
end

EDyearR1 = trapz(0.25*PDresyR1); 

%% Costs demand response
% Also cost of demand response system might be paid by demand response
% profit

%% Plot
%{
%window
figure('Name','Demand response INTERNAL')
set(gcf, 'Position', [100, 100, 1100, 600])

%Demand battery
subplot(2,3,5)
plot(Edb,'r')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Stored demand')
xlabel('Year 2050')
ylabel('MWh')
hold on

%plot day
subplot(2,3,6)
plot(PtoDB((180*96):(181*96)),'b')
hold on
plot(PfrDB((180*96):(181*96)),'r')
xticks([1 tpd/4 tpd/2 (3*tpd)/4 tpd])
xticklabels({'00:00','6:00','12:00','18:00','24:00'})
title('Demand response region: 180st day')
xlabel('Time of Day')
ylabel('MW/15m')
%}