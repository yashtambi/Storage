function [nPanels, cArea] = solarcost(region, totPVArea, PVtotOut, filename)
    %{
        Function to calculate the total number of panels
        required, and return the cost
    %}
    
    data = xlsread(filename);
    
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