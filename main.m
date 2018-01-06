%% Initialization
clear; clc;
t = 0.25:0.25:8760;     % time (in steps of 15 mins)
regions = 5;
regiondata = xlsread('RegionData.xlsx', 'data');
region_distmat = distRegions(regiondata, regions);

clear regiondata


%% Solar
solar_regions = regions;
default_solarfarm_size = 25;    % km2
default_solarfarms = 1;         % number of solar farms in region
default_overall_efficiency = 0.03;

solarirradiation = simportfile('avg_irradiations.xlsx');

% Initialize variables
pvpower = zeros(length(t), solar_regions);
pvarea = zeros(1, solar_regions);
npanels = zeros(1, solar_regions);
pvcost = zeros(1, solar_regions);

for i = 1:solar_regions
    [pvpower(1:end, i), pvarea(i), pvcost(i), npanels(i)] = solarpower(solarirradiation, t, ...
        default_overall_efficiency, i, default_solarfarm_size, default_solarfarms);
end

clear solar_regions default_solarfarm_size default_solarfarms ...
    default_overall_efficiency regiondata i


%% Wind
% Specify filenames
turbine_filename = 'turbinechars.xlsx';

[windspeeds, windparks] = wimportfile('windspeeds.xlsx');

turbine = zeros(1, windparks);
turbinearea = zeros(1, windparks);
turbinecost = zeros(1, windparks);
wpower = zeros(length(t), windparks);   % Wind power for all parks

% This loop automatically selects the best wind turbine for each location
% depending on windspeeds and turbine characteristics
for i = 1:windparks
    [wpower(1:end, i), turbine(i), turbinearea(i), turbinecost(i)] = ...
        turbineselector(turbine_filename, windspeeds, t);
end

clear turbine_filename i wind_r1 windspeeds


%% Demand

%level playing field
lpf  = 0.00004;

%Average demand resonse
dr = 0.3;

tpd = 96;
td = 365;
tpy = td*tpd;
tdy = 1:1:td;
tsy = 1:1:tpy;

%% level playing field
PVoutput  = PVoutput.*lpf*0.001;
PVoutputM = PVoutputM.*lpf*0.001;

%% Residential Demand response
Psupply = PVoutput;
Pdemand = PDRy;

[PDRyresponse,PDRyMresponse,EDRyresponse] = FUNdemandRESPONSE(Psupply,Pdemand,dr);



residential_filename = 'residential_demand.xlsx';
demand_regions = regions;

res_demand = zeros(length(t), demand_regions);

for i = 1:demand_regions
    res_demand(1:end, i) = residentialdemand(i);
end

clear i demand_regions residential_filename


%% Plotting
%{
figure
for i = 1:regions
    try
        supply = (pvpower(1:end, i) * 250) + (wpower(1:end, i) .* 20000);
    catch
        supply = (pvpower(1:end, i) * 200);
    end
        subplot(regions, 1, i);
        plot(t, supply);
        hold on; grid on;
        plot (t, res_demand(1:end, i));
        plot(t, supply - res_demand(1:end, i));
        legend 'Supply' 'Demand' 'Deficit';
        plot_title = "Region " + string(i);
        title (plot_title);
end

clear plot_title i
%}


%% Energy Storage
storageoptions = xlsread('storage/storageoptions.xlsx');


%% Energy Deficit
% figure(2)
nsolarfarms= [1500, 10000, 5000, 5000, 2500];
nwindparks= [1000, 2000, 1000, 10000, 7000];

distribution = [0.5; 0.25; 0.25];% .* ones(min(size(storageoptions)), regions);
capacity = [4; 6; 2];% .* ones(min(size(storageoptions)), regions);

% Calculate demand deficit for each region
demand_deficit = (pvpower .* nsolarfarms) + (wpower .* nwindparks) - res_demand;

estorage = zeros(size(demand_deficit));

for i = 1:regions
    [estorage(:, i)] = ...
        energystorage(demand_deficit(:, i), storageoptions, t, capacity, distribution);
end

plot(t, demand_deficit(:, 3), t, estorage(:, 3))

hold on
grid on

legend 'Demand Deficit' 'Storage' 
