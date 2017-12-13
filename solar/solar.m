
clear; clc;

t = 0.25:0.25:8760;

%% Solar
solar_filename = 'avg_irradiations.xlsx';

%links to excel file of hourly irradiation in wh/m2 for regions 1-5 for the entire year
regiondata = xlsread(solar_filename);
% Region_irradiation = regiondata(:, region); % Region irradiance data

[PVoutput, PVarea] = solarpower(regiondata, t, 0.03, 3, 25, 1000);