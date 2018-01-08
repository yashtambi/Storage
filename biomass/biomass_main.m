clear bioirradiation_var bioirradiation_var_1 loss index crops netpr region solarirradiation

regions = 5;
crops = 5;
solarirradiation = simportfile('avg_irradiations.xlsx');
t = 0.25:0.25:8760;     % time (in steps of 15 mins)

netpr = zeros(regions, 1);

if ~exist('biomassdata', 'var')
    biomassdata_import;
end


%% All regions
loss = 0.05;    % 5%

% Areas for corn, soybeans, switchgrass, wood, algae (hectares)
% respectively
biodiesel_demand = 794;
areas = [0, 6657084.7/2, 0, 0, 0;
    0, 17811040.23/2, 0, 0, 0;
    0, 1902024.2/2, 0, 0, 0;
    0, 7394017.906/2, 0, 0, 7000000;
    0, 100406.9681/2, 0, 0, 7000000;
    ];

waste_biodiesel = [2998800, 17564400, 3141600, 21491400, 5644161.676] / 1e6;

for region = 1:regions
    bioirradiation_var_1 = hourtoquarter(solarirradiation(:, region), t, 1);
    for i = 1:crops
        index = (crops*(i-1)) + region;
        
        bioirradiation_var = bioirradiation(1, bioirradiation_var_1, t, ...
            biomassdata.Plantingtime(index), biomassdata.Harvestingtime(index));
        
        netpr(region) = netpr(region) + biomasstofuel(bioirradiation_var, t, biomassdata.Photosyntheticefficiency(index),...
            biomassdata.Massratiokgproductkgplant(index), areas(i, region), ...
            biomassdata.Ouputinputratiokgkg(index), biomassdata.Harvestingtime(index), loss);
    end
end

netpr = netpr ./ 1e6; % Convert MWh to TWh
biodiesel_total = sum(netpr) - sum(waste_biodiesel);