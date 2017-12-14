function y = objective(vars, regions, farmarea, turbinearea, demand, solar, wind)
    %{
        Objective 1: minimize the total area occupied by solar and wind
        farms
        Objective 2: minimize the power / energy deficit
            Variables required:
                > power output per solar plant per region
                > number of solar plants per region
                > power output per wind turbine per region
                > area occupied by per solar plant per region
                > area occupied by per wind turbine per region
                > demand per region
                > demand response per region (optional)
    %}
    
    solarfarms = vars(1:regions);           % Number of wind farms in each region
    windfarms = vars(regions+1:end);        % Number of wind turbines in each region
    
    solararea = solarfarms .* farmarea;
    windarea = turbinearea .* windfarms;
    
    totarea = sum(solararea) + sum(windarea);
    y(2) = totarea;                         % Objective 2 -> Minimize total area
    
    supply = (solarfarms .* solar) + (windfarms .* wind);
    y(1) = sum(sum(demand-supply));
end