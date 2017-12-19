storage.m

%% Optimization
% Objective function
fitnessfcn = @(x)objective(x, regions, PVarea, turbinearea, res_demand, PVoutput, wpower);

% Constraints
nvars = length(PVarea) + length(turbine);
area_covered = [PVarea turbinearea];
A = area_covered;
b = areapercent_max * sum(regionarea) * 1e6; % convert to m^2
lb = zeros(1, nvars);
ub = [];

% Optimization
options = optimoptions(@gamultiobj, 'PlotFcn', @gaplotpareto);
[x, Fval, exitFlag, Output] = gamultiobj(fitnessfcn, nvars, A, b, [], [], lb, ub, options);