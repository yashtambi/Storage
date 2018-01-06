function [total] = Biomass2(region, starthour, endhour)
%{
        t = hours in the year
        region = region_number
%}

%links to excel file of hourly irradiation in wh/m2 for regions 1-5 for the entire year
regiondata = xlsread('Average_Irradiations.xlsx');
Region_irradiation = regiondata(:, region); % Region irradiance data
t = 0.25: 0.25: 8760;

% Interpolation for increasing data points(15-min interval)
if length(Region_irradiation) ~= length(t)
    Region_irradiation2 = zeros(length(t),1);
    j = 1;
    for i = 1:length(Region_irradiation)
        Region_irradiation2(j:(j+(1/0.25))-1) = Region_irradiation(i);
        j = j+4;
    end
    Region_irradiation = Region_irradiation2;
end
Region_irradiation(t<starthour) = 0; %correction for zero production before planting species
total=cumtrapz(Region_irradiation*(1/3.6)*10^-9*15*60); %accumulated solar energy throughout the year in MWh
endval = total(endhour/0.25); %correction for stagnated production after harvesting
total(t>endhour) = endval;

% total(t<starthour) = 0;
% total(t>endhour) = 0;

