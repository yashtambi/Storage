function [windspeeds, windparks] = wimportfile(filename, region)
    windspeeds = xlsread(filename);
    if nargin > 2
        windspeeds = windspeeds(:,region);
        return
    end
    windparks = min(size(windspeeds));
    if max(size(windspeeds)) < 8760
        missingelements = 8760 - max(size(windspeeds));
        % inserting a 0 at the start as there are only 8759 elements initially
        windspeeds = [zeros(missingelements, windparks); windspeeds]; 
    end
end


