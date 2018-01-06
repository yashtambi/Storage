function [tofuel] = Biomass3(total, photo, mass, hectare, inputratio)
%{
        photo = photosynthetic efficiency of the species (solar energy %
        which is saved in plant)
        mass = mass efficiency (kg of biofuel/plastic per kg of plant)
        hectare = amount of hectares used 
        inputratio = yield in MWh at certain moment corrected for fuel use
        to make biofuel/plastic
        tofuel = calculated net energy content of the fuel in MWh at certain moment
%}
    y=total;
    tofuel=y.*photo.*mass.*hectare*10000.*inputratio;
end
