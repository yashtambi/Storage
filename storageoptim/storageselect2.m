function [ estorage, droppedload ] = storageselect2( feed, instcap, ...
        avcapmax, ceff, deff, crate, interval )
    %STORAGEOPTIONS2 Summary of this function goes here
    %   Detailed explanation goes here
    
    storagetypes = length(instcap);    
    estorage = zeros(length(feed) + 1, storagetypes);
    
    opts = optimoptions(@fmincon, 'Display', 'off', 'MaxIterations', 250);
    
    for i = 1:length(feed)
        estorage(i+1, :) = estorage(i, :) + optim(feed(i), estorage(i, :), ...
            avcapmax, instcap, crate, ceff, deff, interval, opts);
    end
    
    estorage = estorage(2 : end);
    droppedload = trapz(feed(estorage == 0)) * interval;
end

