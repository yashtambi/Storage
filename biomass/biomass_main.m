regions = 5;
solarirradiation = simportfile('avg_irradiations.xlsx');
t = 0.25:0.25:8760;     % time (in steps of 15 mins)

solarirradiation = hourtoquarter(solarirradiation, t, 1);

bioirradiation_var = zeros(regions, sizeof(t));
tofuel = zeros(regions, sizeof(t));
netpr = zeros(regions, sizeof(t));

for i = 1:regions
    [bioirradiation_var(i, :)] = bioirradiation(i, solarirradiation, t, 2976, 5304);
    [tofuel(i, :), netpr(i, :)] = biomasstofuel(total, t, 0.025, 0.40, 889, 0.34, 5304, 0.05);
end
