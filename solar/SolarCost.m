function [nPanels, totCost] = SolarCost(PVtotalIrr, PVtotOut)
    
    %{
        Function to calculate the total number of panels
        required, and return the cost
    %}
    
    data = xlsread('PanelProperties.xlsx');
    
    panelProperties = table;
    panelProperties.efficiency = data(:,1);
    panelProperties.powerPerPanel = data(:,2);
    panelProperties.areaPerPanel = data(:,3);
    panelProperties.cost = data(:,4);
    
    capfactor = (PVtotalIrr * 1000)/8760;
    PVcapacity = PVtotOut/(capfactor * 8760);
    nPanels = round(PVcapacity./ panelProperties.powerPerPanel);
    totCost = panelProperties.cost .* nPanels;
end