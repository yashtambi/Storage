function [irradiation, regionareas] = simportfile(filename, region)
    irradiation = xlsread(filename);
    if nargin > 2
        irradiation = irradiation(:,region);
        return
    end
    
    if nargout > 1
        regionareas = irradiation(1:regions, min(size(irradiation)));
    end
    
    irradiation = irradiation(:,1:min(size(irradiation))-1);
end


