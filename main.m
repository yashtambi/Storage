%% Initialization
clear; clc;
t = 0.25:0.25:8760;     % time (in steps of 15 mins)
regions = 5;
region_filename = 'RegionData.xlsx';
regiondata = xlsread(region_filename, 'data');
region_distmat = distRegions(regiondata, regions);

clear regiondata


%% Solar
solar_regions = regions;
default_solarfarm_size = 25;    % km2
default_solarfarms = 1;         % number of solar farms in region
default_overall_efficiency = 0.3;

solar_filename = 'avg_irradiations.xlsx';

% Links to excel file of hourly irradiation in wh/m2 for regions 1-5 for the entire year
solarirradiation = xlsread(solar_filename);
regionarea = solarirradiation(1:regions, 6);        % total areas of the regions

% Initialize variables
PVoutput = zeros(length(t), solar_regions);
PVarea = zeros(1, solar_regions);
nPanels = zeros(1, solar_regions);
PVcost = zeros(1, solar_regions);

for i = 1:solar_regions
    [PVoutput(1:end, i), PVarea(i), PVcost(i), nPanels(i)] = solarpower(solarirradiation, t, ...
        default_overall_efficiency, i, default_solarfarm_size, default_solarfarms);
end

clear solar_regions default_solarfarm_size default_solarfarms ...
    default_overall_efficiency solar_filename regiondata i


%% Wind
windparks = 1;  % Max windparks

% Specify filenames
turbine_filename = 'turbinechars.xlsx';
windspeeds_filename = 'windspeeds.csv';

turbine = zeros(1, windparks);
turbinearea = zeros(1, windparks);
turbinecost = zeros(1, windparks);
wpower = zeros(length(t), windparks);   % Wind power for all parks

% This loop automatically selects the best wind turbine for each location
for i = 1:windparks
    % Import wind speed data
    % 2nd argument will be read as (arg+2) to read the column from the file
    wind_r1 = wimportfile(windspeeds_filename, i);
    wind_r1 = [0 wind_r1']; % inserting a 0 at the start as there are only 8759 elements initially
    % Get the wind speed data for a particular region for 1 turbine (selected
    % automatically from the given list of turbines to get max power output)
    [wpower(1:end, i), turbine(i), turbinearea(i), turbinecost(i)] = ...
        turbineselector(turbine_filename, wind_r1, t);
end

clear turbine_filename windspeeds_filename i wind_r1


%% Demand
residential_filename = 'residential_demand.xlsx';
demand_regions = regions;

res_demand = zeros(length(t), demand_regions);

for i = 1:demand_regions
    res_demand(1:end, i) = FUNdemandRES(i);
end

clear i demand_regions residential_filename


%% Plotting
figure
subplot(regions, 1, 1);

for i = 1:regions
    subplot(regions, 1, i);
    try
        supply = (PVoutput(1:end, i) * 250) + (wpower(1:end, i) .* 20000);
    catch       % If there are no more wind parks
        supply = (PVoutput(1:end, i) * 2000);
    end
    plot(t, supply);
    hold on; grid on;
    plot (t, res_demand(1:end, i));
    plot(t, supply - res_demand(1:end, i));
    legend 'Supply' 'Demand' 'Deficit';
    plot_title = "Region " + string(i);
    title (plot_title);
end

clear plot_title i 


%% Energy Storage
storageoptions = xlsread('storage/storageoptions.xlsx');


%% Energy Deficit
figure(2)
demand_deficit = (PVoutput(1:end, 1) * 150) + (wpower(1:end, 1) .* 1000)...
    - res_demand(1:end, 1);
distribution = [0.5 0.25 0.25];
capacity = [4 4 4];
[estorage, unservedload] = energystorage(demand_deficit', storageoptions, t, capacity, distribution);
plot(t, estorage, t, demand_deficit);
hold on
grid on

legend 'battery' 'demand_deficit'
