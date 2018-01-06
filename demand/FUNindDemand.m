function [PIelt,EIelt,PIh2t,EIh2t,PInh3t,EInh3t,PIbioft] = FUNindDemand(r,eor)

%ratio regions USA
r1=0.0572;
r2=0.4012;
r3=0.2955;
r4=0.2460;

%population growth to 2050
G = [1.26,1.26,1.26,1.26,1.36];
%Efficiency improvements to 2050
E = [0.2,0.2,0.2,0.2,0.2];

%% time
t   =1:35040;
tpd = 96;
td  = 365;
tpy = td*tpd;
tdy = 1:1:td;
tsy = 1:1:tpy;

%Coal [KWh]
Ecoal   = [r1*7.11e10, r2*7.11e10, r3*7.11e10, r4*7.11e10, 3.05e10];
%Oil [KWh]
Eoil    = [r1*2.52e11, r2*2.52e11, r3*2.52e11, r4*2.52e11, 6.76e10];
%NatGas [KWh]
Engas   = [r1*1.41e12, r2*1.41e12, r3*1.41e12, r4*1.41e12, 1.39e11];
%Biofuels + waster [KWh]
Ebiofuel= [r1*3.50e11, r2*3.50e11, r3*3.50e11, r4*3.50e11,  1.05e10];
%Electricity [KWh]
Eelec   = [r1*8.21e11, r2*8.21e11, r3*8.21e11, r4*8.21e11, 1.42e11];
%Heat [KWh]
Eheat   = [r1*5.14e10, r2*5.14e10, r3*5.14e10, r4*5.14e10, 1.15e8];

%% random curves year
rdv= zeros(1,tpy);
rdm= zeros(6,tpy);
for k = 1:6
    rng('shuffle')
    rd = randi([1 30],1,1);
    for j = 1:rd

        rd1 = (rand-0.5)/40;
        rd3 = randi([10 5000],1,1);
        rd2 = randi([1 35000-rd3],1,1);

        td0 = 1:1:rd3;
        vec1 = zeros(1,tpy);
        fluc1 = -(rd1)*sin(2*pi*(td0+(rd3/4))/(rd3))+(rd1); 

        for i = 1:rd3                                  
        vec1(1,(rd2)+i) = fluc1(i);
        end

        rdv=rdv+vec1;
        for p = 1:tpy
            rdm(k,p) = rdv(p);
        end
    end    
end

clear rd rd1 rd2 rd3 td0 vec1 fluc1 i j p k rdv


%% Industry Demand
Pindcoal  = (ones(1,tpy)+rdm(1,1:tpy)).*G(r)*(1-E(r))*(Ecoal(r)/(365*24))*0.001;
Pindoil   = (ones(1,tpy)+rdm(2,1:tpy)).*G(r)*(1-E(r))*(Eoil(r)/(365*24))*0.001;
Pindgas   = (ones(1,tpy)+rdm(3,1:tpy)).*G(r)*(1-E(r))*(Engas(r)/(365*24))*0.001;
Pindbiof  = (ones(1,tpy)+rdm(4,1:tpy)).*G(r)*(1-E(r))*(Ebiofuel(r)/(365*24))*0.001;
Pindelect = (ones(1,tpy)+rdm(5,1:tpy)).*G(r)*(1-E(r))*(Eelec(r)/(365*24))*0.001;
Pindheat  = (ones(1,tpy)+rdm(6,1:tpy)).*G(r)*(1-E(r))*(Eheat(r)/(365*24))*0.001;


Pindtotal = Pindcoal + Pindoil + Pindgas + Pindbiof + Pindelect + Pindheat;

EDyearI1 = trapz(0.25*Pindtotal);

%% Industry 2050

    % Electric
    PIel = Pindelect + Pindheat + 0.2*Pindoil;
    
    % H2
    PIh2 = 0.6*Pindgas + 0.1*Pindoil + 0.2*Pindcoal;
    %would consume 39.4 (100%) to 65 kilowatt-hours electricity per kilogram for 33.3
    %KWH per kilogram of H2
    
    % NH3
    PInh3 = 0.2*Pindoil + 0.5*Pindcoal + 0.4*Pindgas;
    
    %http://www.hydroworld.com/articles/hr/print/volume-28/issue-7/articles/renewable-fuels-manufacturing.html
    %12 KWH/kg electricity for 5.16 KWh/Kg of ammonia
    
    
    % Biofuel
    PIbiof = Pindbiof + 0.3*Pindcoal+ 0.5*Pindoil;
    EDIbiof = trapz(0.25*PIbiof);
 
%% CONVERSIONS
PIelt  = PIel + eor(1)*1.65.*PIh2 +eor(2)*2.3256.*PInh3;    %MW
EIelt = trapz(0.25*PIelt);                                 %MWh
PIh2t  = (1-eor(1)).*PIh2;                                  %MW
EIh2t = trapz(0.25*PIh2t);                                 %MWh
PInh3t = (1-eor(2)).*PInh3;                                 %MW
EInh3t = trapz(0.25*PInh3t);                               %MWh

% average MWH to kg
% (https://en.wikipedia.org/wiki/Energy_content_of_biofuel)
%0,0104999 MWh per KG

PIbioft= PIbiof .*(1/0.0104999);                            %Kg


%% Plot Internal
%{
%window
figure('Name','Demand response INTERNAL')
set(gcf, 'Position', [100, 100, 1100, 600])

%Demand battery
subplot(2,3,5)
plot(rdm(1,1:tpy))
hold on
plot(rdm(2,1:tpy))
plot(rdm(3,1:tpy))
plot(rdm(4,1:tpy))
plot(rdm(5,1:tpy))
plot(rdm(6,1:tpy))
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Random')
xlabel('Year 2050')
ylabel('%')
hold on

%demand industry
subplot(2,3,1)
plot(PIel,'y')
hold on
plot(PIh2,'b')
plot(PInh3,'r')
plot(PIbiof,'g')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Demand Industry with out conversion')
xlabel('Year 2050')
ylabel('MW')
hold on

%demand industry
subplot(2,3,2)
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
subplot(2,3,3)
plot(PIbioft,'g')
xticks([1 tpy/4 tpy/2 (3*tpy)/4 tpy])
xticklabels({'January','March','June','September','December'})
title('Demand Biofuels')
xlabel('Year 2050')
ylabel('Kg')
hold on
%}