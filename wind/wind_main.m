%{
    At the end of this file,
    I should get a set of data:
        > wind potential in the region (data points)
        > specifications of wind turbines
%}

% Time (in 15 mins intervals) for a year
t = 0.25:0.25:8760;
windparks = 1;

% Clear variables
clear wind_r1 opspeed oppower turbine maxenergy turbine_filename windspeeds_filename;

% Specify filenames
turbine_filename = 'turbinechars.xlsx';
windspeeds_filename = 'windspeeds.csv';

turbine = zeros(1, windparks);
wpower = zeros(windparks, length(t));   % Wind power for all parks
wspeed = zeros(windparks, length(t));   % Wind speeds for all parks

% This loop automatically selects the best wind turbine for each location
for i = 1:windparks
    % Import wind speed data
    % 2nd argument will be read as (arg+2) to read the column from the file
    wind_r1 = wimportfile(windspeeds_filename, i);
    wind_r1 = [0 wind_r1']; % inserting a 0 at the start as there are only 8759 elements initially
    % Get the wind speed data for a particular region for 1 turbine (selected
    % automatically from the given list of turbines to get max power output)
    [wpower(i), turbine(i), wspeed(i)] = turbineselector(turbine_filename, wind_r1, t);
end

% Get the wind speed data for a particular region for 1 turbine (selected
% automatically from the given list of turbines to get max power output)

[opspeed, wpower, turbine, maxenergy] = turbineselector(turbine_filename, wind_r1, t, turbine);

plot(t, wpower);
legend 'Wind Power'; grid on; hold on;
xlabel 'Hour of the year'; ylabel 'Actual power output (in Wh/h)'