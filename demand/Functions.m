clc
clear
close all

%region
r    = 3;

%level playing field
lpf  = 0.00004;

%Average demand resonse
dr = 0.3;

%% time
t=1:35040;
tpd = 96;
td = 365;
tpy = td*tpd;
tdy = 1:1:td;
tsy = 1:1:tpy;

%% Powers one region

%residential demand
[PDRy,PDRyM,EDRdS,EDRdW,EDRy] = FUNdemandRES(r);

%Solar supply
[PVoutput, PVoutputM, PVarea, PVtotalIrr, PVtotOut] = solarpower(t,0.03,0.10,r);

%% level playing field
PVoutput  = PVoutput.*lpf*0.001;
PVoutputM = PVoutputM.*lpf*0.001;

%% Residential Demand response
Psupply = PVoutput;
Pdemand = PDRy;

[PDRyresponse,PDRyMresponse,EDRyresponse] = FUNdemandRESPONSE(Psupply,Pdemand,dr);

%% HYDROELECTRICITY

%new demand
Pdemand = PDRyresponse;
Psupply = PVoutput;

%[Power hydro vector, Power hydro matrix, Energy per year, Area needed per
%region, Average cost per region]
[PShydro,PShydroM,EHSyear,AHA,CHA] = FUNsupplyHYDRO(Pdemand, Psupply, r);

%new supply
Psupply = PVoutput + PShydro';

%% INDUSTRY DEMAND
%[factor of h2 in electricity, factor of nh3 in electricity]
eor = [1, 1]; 

%[total electric demand MW, Energy electricity demand MWh, total h2 demand MW, Energy
%h2 demand MWh, total nh3 demand MW, Energy nh3 demand MWh, total biofuel demand kg]

[PIelt,EIelt,PIh2t,EIh2t,PInh3t,EInh3t,PIbioft] = FUNindDemand(r,eor);

%% Plot

%window
figure('Name','Demand response')
set(gcf, 'Position', [100, 100, 1100, 600])

%Residential power demand
subplot(2,3,1)
plot(PDRy,'b')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Residential Power Demand')
xlabel('Year 2050')
ylabel('MW/15m')
hold on

%Residential power demand
subplot(2,3,2)
plot(PVoutput,'g')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Solar Power Supply')
xlabel('Year 2050')
ylabel('MW/15m')
hold on

%Residential power demand
subplot(2,3,3)
plot(PDRyresponse,'b')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Residential Power Demand with response')
xlabel('Year 2050')
ylabel('MW/15m')
hold on

%plot day
subplot(2,3,4)
plot(PVoutputM(180,1:96),'b')
hold on
plot(PDRyM(180,1:96),'g')
plot(PDRyMresponse(180,1:96),'r')
plot(Psupply(180*96:181*96),'m')
legend('Psolar','Residentialdemand','Residentialdemandresponse','PV+hydro')
xticks([1 tpd/4 tpd/2 (3*tpd)/4 tpd])
xticklabels({'00:00','6:00','12:00','18:00','24:00'})
title('Power: 180st day')
xlabel('Time of Day')
ylabel('MW/15m')

%demand industry
subplot(2,3,5)
plot(PIelt,'y')
hold on
plot(PIh2t,'b')
plot(PInh3t,'r')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Demand Industry')
xlabel('Year 2050')
ylabel('MW')
hold on

%demand industry biofuel
subplot(2,3,6)
plot(PIbioft,'g')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Demand Biofuels')
xlabel('Year 2050')
ylabel('Kg')
hold on
