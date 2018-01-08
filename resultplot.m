subplot(2, 2, 1);
plot(t, (estorage(1, :)));
title 'Time of year vs Battery Storage';
xlabel 'Time (in 15 min interval)'
ylabel 'Energy available in storage (MWh)'

subplot(2, 2, 2);
plot(t, estorage(2, :));
title 'Time of year vs Hydrogen Storage';
xlabel 'Time (in 15 min interval)'
ylabel 'Energy available in storage (MWh)'

subplot(2, 2, 3);
plot(t, (estorage(3, :)));
title 'Time of year vs Pumped Hydro Storage';
xlabel 'Time (in 15 min interval)'
ylabel 'Energy available in storage (MWh)'

subplot(2, 2, 4);
plot(t, estorage(1, :), t, estorage(2, :), t, estorage(3, :));
title 'Time of year vs all Storage';
xlabel 'Time (in 15 min interval)'
ylabel 'Energy available in storage (MWh)'
legend 'Hydrogen' 'Pumped Hydro' 'Battery'