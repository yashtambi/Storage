function [total] = bioirradiation(region, regiondata, t, starthour, endhour)
    %{
        t = hours in the year
        region = region_number
    %}
    
    Region_irradiation = regiondata(:, region); % Region irradiance data
    
    if length(Region_irradiation) ~= length(t)
        Region_irradiation = hourtoquarter(Region_irradiation, t, 1);
        Region_irradiation(Region_irradiation < 0) = 0;
    end
    
    Region_irradiation(t<starthour) = 0; %correction for zero production before planting species
    total=cumtrapz(Region_irradiation*(1/3.6)*10^-9*15*60); %accumulated solar energy throughout the year in MWh
    endval = total(endhour/0.25); %correction for stagnated production after harvesting
    total(t>endhour) = endval;
end