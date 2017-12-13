function [oppower, turbine, opspeed, maxenergy, turbinearea, turbinecost] = turbineselector(filename, ipspeed, t, sturbine)
    %{
        This function selects the best wind turbine out of all available
        for the given wind speed range and returns the said data. 
            
        This function takes the below described arguments, selects the best
        turbine amongst those available, and returns the data (see below).
        If data for a particular turbine type is required instead, values
        should be passed into the optional variable 'sturbine'.
    
        Args:
            filename:   name of file containing turbine properties
            ipspeed:    wind speed data for the region
            t:          time
            sturbine: by default, this function will select the best
                turbine and compute data for it. If a specific turbine is
                required, that turbine number should be passed as argument
                to this variable.
                <Note> this is an optional input.
        Returns:
            opspeed:    wind speed data changed as per turbine
            rated/cutin/cutout speeds
            turbine:    turbine which gives max output
            maxenergy:  total max energy output from the turbine for the
            entire year
            <Optional Returns>
            turbinearea: Area for 1 turbine
            turbinecost: Cost for the selected turbine
    %}
    
    defaultinterval = 15/60;        % Default time interval in minutes
    interval = t(2) - t(1);
    if interval ~= defaultinterval
        error('Time not in default interval period')
    end
    if length(ipspeed) ~= length(t)
        ipspeed = hourtoquarter(ipspeed, t); % interpolates hourly data to quarterly data
        ipspeed = ipspeed';
    end
    
    tchars = xlsread(filename);
    
    totalenergy = size(tchars);
    totalenergy = zeros(1, totalenergy(1));
    
    if nargin < 4
        for i = 1:length(totalenergy)
            totalenergy(i) = turbinechars(tchars, ipspeed, t, i, interval);
        end
        turbine = find(totalenergy == max(totalenergy));
    else
        turbine = sturbine;
    end
    
    [maxenergy, opspeed, oppower] = turbinechars(tchars, ipspeed, t, turbine, interval);
    
    % Return turbine area and cost if asked for
    if nargout > 4
        turbinearea = tchars(turbine, 7);
        if nargout > 5
            turbinecost = tchars(turbine, 8);
        end
    end
end
