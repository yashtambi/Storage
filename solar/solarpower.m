function [PVoutput, PVarea, PVtotalIrr, PVtotOut] = solarpower(regiondata, t, ...
        efficiency, region, areaperplant, totplants)
    %{
        t = hours in the year
        efficiency = net efficiency (i.e PV*system*area efficiency),
        areapercent = how much % of area of that region we want to cover with pv
        region = region_number
        Region_Irradiation = solar irradiation in matrix (hourly)
        %}
        
        if nargin < 5
            areaperplant = 16*1e6;
            totplants = 10;
        elseif nargin < 6
            totplants = 10;
        else
            areaperplant = areaperplant*1e6;       % Convert km2 to m2
        end
        
        PVarea = areaperplant * totplants;  % Total plant area
        Region_irradiation = regiondata(:, region); % Region irradiance data
        tinterval = abs(t(2)-t(1));
        
        % Interpolation for increasing data points(15-min interval)
        % Todo: can use this as a cloud factor / windfactor combination
        if length(Region_irradiation) ~= length(t)
            Region_irradiation2 = zeros(length(t),1);
            j = 1;
            for i = 1:length(Region_irradiation)
                Region_irradiation2(j:(j+(1/0.25))-1) = Region_irradiation(i);
                j = j+4;
            end
            Region_irradiation = Region_irradiation2;
        end
        
        clear Region_irradiation2;
        Region_irradiation = Region_irradiation/10e6;           % Convert to MWh/h
        
        PVoutput = Region_irradiation .* efficiency .* PVarea;   % Hourly pv power output in Wh/hour
        
        if nargout > 2
            PVtotalIrr = trapz(t, Region_irradiation) * tinterval;     % Wh
            if nargout > 3
                PVtotOut = trapz(t, PVoutput) * tinterval;             % Wh
            end
        end
        
%         %% Plot
%         legendName = "Region: " + string(region);
%         plot(t, PVoutput, 'DisplayName', legendName);
%         legend('-DynamicLegend');
%         xlabel('Hours in year');
%         ylabel('Solar pv output in Mwh/hr');
%         title('PV output hourly, annual');
%         hold on
%         grid on