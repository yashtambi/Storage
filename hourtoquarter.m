function [ opdata ] = hourtoquarter( ipdata, t, noiseamp )
    % Interpolation for increasing data points(15-min interval)
    % Todo: can use this as a cloud factor / windfactor combination
    
    coeff = 0;
    if nargin > 2
        coeff = 1;
    else
        noiseamp = 1;
    end
    
    if length(ipdata) ~= length(t)
        opdata = zeros(length(t),1);
        j = 1;
        for i = 1:length(ipdata)
            opdata(j:(j+(1/0.25))-1) = ipdata(i) + (coeff*wgn(1,(1/0.25), noiseamp));
            j = j+4;
        end
    end
end

