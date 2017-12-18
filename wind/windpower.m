function oppower = windpower(ipspeed, t, rotordia, ne)
    %{
        This function computes the power output from the turbine using the
        simple formula:
            P = 0.5 * air_density * rotor_area * wind_velocity^3
        and finally is multiplied by the number of seconds, to gve the
        output in Wh/h units. 
    
        Args:
            rotordia = rotor blade diameter in meter
            ipspeed = wind speed in meter per second
            oppower = power in the wind hitting 1 turbine (in Watts)
            interval: time steps (in hours) (optional)
    %}
    
    if nargin < 5
        interval = t(2) - t(1);
    end
    
%     totalseconds = 60*60*interval;
    
    density = 1.3; % Densiy of air in kg per square meter
    oppower = (0.5 * density * pi * (rotordia/2)^2 .* (ipspeed.^3)) * ne;
    
%     oppower = oppower .* totalseconds;
end