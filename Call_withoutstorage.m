%% Initialization
clear; clc;
t = 0.25:0.25:8760;     % time (in steps of 15 mins)
regions = 5;
region_filename = 'RegionData.xlsx';
regiondata = xlsread(region_filename, 'data');
region_distmat = distRegions(regiondata, regions);


%% Solar
solar_regions = regions;
default_overall_efficiency = 0.3;

solar_filename = 'avg_irradiations.xlsx';

% Links to excel file of hourly irradiation in wh/m2 for regions 1-5 for the entire year
solarirradiation = xlsread(solar_filename);
regionarea = solarirradiation(1:regions, 6);        % total areas of the regions

% Initialize variables
PVoutput = zeros(length(t), solar_regions);


for i = 1:solar_regions
    [PVoutput(1:end, i)] = solarpower(solarirradiation, t, ...
        default_overall_efficiency, i);
end

clear solar_regions default_solarfarm_size default_solarfarms ...
    default_overall_efficiency solar_filename regiondata i


%% Wind
windparks = 1;  % Max windparks

% Specify filenames
turbine_filename = 'turbinechars.xlsx';
windspeeds_filename = 'windspeeds.xlsx';

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

%% Temporary hydro constant generation in MWh/m2
hydropower=zeros(1,35040);
for i=1:35040
hydropower(i)=3.5E-04;
end
clear i
%% Optimizer
%Initializing
power1=zeros(35040,3);power2=zeros(35040,3);power3=zeros(35040,3);power4=zeros(35040,3);power5=zeros(35040,3);
cost1=zeros(35040);cost2=zeros(35040);cost3=zeros(35040);cost4=zeros(35040);cost5=zeros(35040);
    for i=1:35040
        
        [power1(i,:),cost1(i)]=Without_storage(PVoutput(i,1),wpower(i,1),hydropower(i),1, res_demand(i,1));
        [power2(i,:),cost2(i)]=Without_storage(PVoutput(i,2),wpower(i,2),hydropower(i),2, res_demand(i,2));
        [power3(i,:),cost3(i)]=Without_storage(PVoutput(i,3),wpower(i,3),hydropower(i),3, res_demand(i,3));
        [power4(i,:),cost4(i)]=Without_storage(PVoutput(i,4),wpower(i,4),hydropower(i),4, res_demand(i,4));
        [power5(i,:),cost5(i)]=Without_storage(PVoutput(i,5),wpower(i,5),hydropower(i),5, res_demand(i,5));
    end

        
        
