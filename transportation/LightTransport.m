%This file is used to calculate the total energy consumption of light road
%transportation in the US in 2050

clc
clear all

load PopAr.mat
load RoadMilMilesGal.mat

t=linspace(2016,2050,35);

datayears=RoadMilMilesGal(1,linspace(1,26,26));
milesdriven=10^6*RoadMilMilesGal(2,linspace(1,26,26));

futuremiles=interp1(datayears,milesdriven,2050,'linear','extrap');

energyconsumption=200; %future energy consumption from light vehicles in wh/mile, note this value is low due to platooning which will reduce consumption
gridtobateffy=0.9; %the efficiency achieved from taking energy from the grid to getting it from the battery

totalpop=sum(PopAr(linspace(1,5,5),1));
milesperstate=(PopAr(linspace(1,5,5),1)/totalpop)*futuremiles;

energy=milesperstate*energyconsumption/(1000*gridtobateffy);

