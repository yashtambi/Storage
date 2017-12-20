clear; clc;

% feed = -12;

% The dimentions of the below 5 should be the same
% ceff = [0.9, 0.8, 0.8];     % Charge efficiency
% deff = [0.9, 0.65, 0.95];   % Discharge efficiency
% estorage = [2, 3, 4];       % Current energy content
% avcapmax = [3, 4, 50];      % Max available
instcap = [4, 5, 100];      % Installed capacity
% crate = [0.9, 0.8, 0.01];   % Crate max
interval = 0.25;

storageoptions = xlsread('storageoptions2.xlsx');
ceff = storageoptions(:, 2);
deff = storageoptions(:, 3);
crate = storageoptions(:, 4);
instcap = instcap .* 1e6; 
avcapmax = instcap .* storageoptions(:, 5);

% [eval, excess] = optim(feed, estorage, avcapmax, instcap, crate, ceff, deff, interval);

storageselect2(feed, instcap, avcapmax, ceff, deff, crate, interval);


