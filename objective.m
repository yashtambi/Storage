function y = objective(demand, solarplants, areaperplant, ...
        turbines, areaperturbine)
    
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
        
        clear; clc;
        clear wind_r1 opspeed oppower turbine maxenergy turbine_filename windspeeds_filename;
        
        t = 0.25:0.25:8760;
        
        % Specify filenames
        turbine_filename = 'turbinechars.xlsx';
        windspeeds_filename = 'windspeeds.csv';
        
        % Import wind speed data
        % 2nd argument will be read as (arg+2) to read the column from the file
        wind_r1 = wimportfile(windspeeds_filename, 1);
        wind_r1 = [0 wind_r1']; % inserting a 0 at the start as there are only 8759 elements initially
        
        % Get the wind speed data for a particular region for 1 turbine (selected
        % automatically from the given list of turbines to get max power output)
        [opspeed, oppower, turbine, maxenergy] = turbineselector(turbine_filename, wind_r1, t);
        
        [PVoutput, PVarea, PVtotalIrr, PVtotOut] = solarpower(t, 0.03, 3, 25, 1000);
        
        [PDRdS, PDRdW, PDRy, EDRdS, EDRdW, EDRy] = FUNdemandRES(3);
        
        clear PDRdS PDRdW EDRdS EDRdW EDRy PVtotalIrr opspeed;
        
        PDRy = PDRy./1000;      % Convert into MWh
        
        for i = 1:regions
            [opspeed, oppower, turbine, maxenergy] = turbineselector(turbine_filename, wind_r1, t);
            wind(i) = 
        end
        
        
end