function [netpr] = Biomass4(tofuel, endhour, loss)
%{
        loss = loss estimation due to trasport/storage of biomass
        netpr = netto production in MWh per year of certain
        biofuel/plastic per region
%}

t = 0.25: 0.25: 8760;    
z=tofuel(t==endhour);
netpr=z.*(1-loss);
    end