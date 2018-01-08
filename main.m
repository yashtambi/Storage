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
pvpower = zeros(solar_regions, length(t));
pvarea = zeros(1, solar_regions);
npanels = zeros(1, solar_regions);
pvcost = zeros(1, solar_regions);

for i = 1:solar_regions
    [pvpower(i, 1:end), pvarea(i), pvcost(i), npanels(i)] = solarpower(solarirradiation, t, ...
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
wpower = zeros(windparks, length(t));   % Wind power for all parks

% This loop automatically selects the best wind turbine for each location
% depending on windspeeds and turbine characteristics
for i = 1:windparks
    [wpower(i, 1:end), turbine(i), turbinearea(i), turbinecost(i)] = ...
        turbineselector(turbine_filename, windspeeds, t);
end

clear turbine_filename i wind_r1 windspeeds


%% Demand
residential_filename = 'residential_demand.xlsx';
demand_regions = regions;
transport=xlsread('transport.xlsx');
transport_demand=zeros(length(t),regions);

tlosses = [1.05, 0.85, 1.45, 0.85, 1.05];

res_demand = zeros(length(t), demand_regions);
industry_demand=zeros(demand_regions,1);
demandtime=zeros(1,demand_regions);
for i = 1:demand_regions
    res_demand(1:end, i) = residentialdemand(i);
    %transport_demand(:,i)=transport(:,i);
    industry_demand(i)=transport((i+1),8);
    
end
totaldemand=zeros(length(t), demand_regions);
for i=1:demand_regions
    for j=1:length(t)
        totaldemand(j,i)=res_demand(j,i)+transport(j,i)+industry_demand(i);
    end
    totaldemand(:,i) = totaldemand(:,i) .* tlosses(i);
end
totaldemand(isnan(totaldemand)) = 0;
totaldemand = sum(totaldemand, 2);

clear i demand_regions residential_filename


%% Energy Storage
storageoptions = xlsread('storageoptions2.xlsx');
instcap = [40; 60; 2000];
ceff = storageoptions(:, 2);
deff = storageoptions(:, 3);
crate = storageoptions(:, 4);
instcap = instcap .* 1e6; 
avcapmax = instcap .* storageoptions(:, 5);
interval = t(2) - t(1);


%% Energy Deficit
% figure(2)
nsolarfarms= [150000; 1000000; 500000; 250000; 500000];
nwindparks= [100000; 200000; 100000; 1000000; 700000];

% Calculate demand deficit for each region
% demand_deficit = (pvpower .* nsolarfarms) + (wpower .* nwindparks) - res_demand;

totalsupply = sum((pvpower .* nsolarfarms) + (wpower .* nwindparks), 1);
demand_deficit = totalsupply - totaldemand';

estorage = storageselect2(demand_deficit, instcap, avcapmax, ceff, ...
    deff, crate, interval, storageoptions);

fprintf('Optimization complete\n');

resultplot.m