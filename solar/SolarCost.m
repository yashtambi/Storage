function [nPanels, totCost] = solarcost(region, totPVArea)
%{
        Function to calculate the total number of panels
        required, and return the cost
        
        Todo: ask Sukanya for cost and no. of panels formula
%}


data = xlsread('PanelProperties.xlsx');

panelProperties = table;
panelProperties.efficiency = data(:,1);
panelProperties.powerPerPanel = data(:,2);
panelProperties.areaPerPanel = data(:,3);
panelProperties.cost = data(:,4);

nPanels = round(totPVArea ./ panelProperties.areaPerPanel);
%totPanels_power = round(PVtotOut ./ panelProperties.powerPerPanel);

cArea = panelProperties.cost .* nPanels;
cPower = nPanels * panelProperties.powerPerPanel;
end