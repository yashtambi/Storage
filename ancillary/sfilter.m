function [opdata] = sfilter(ipdata, t, tou)
    %{
        tou: should be in terms of hours, turbine time constant
        Filter equation:
            coeff*(1-exp(-t/tou)), tou = turbine time constant
    %}
    
    interval = t(2) - t(1);              % Spacing
    opdata = zeros(1, length(ipdata));   % Filtered output
    shiftw = [0 ipdata];
    for i = 1:length(ipdata)
        coeff = shiftw(i+1) - opdata(i);
        x = (1-exp(-interval/tou));
        opdata(i+1) = opdata(i) + (coeff * x);
    end
    opdata = opdata(2:end);
end