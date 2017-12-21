function [ estorage, droppedload ] = storageselect2( feed, instcap, ...
        avcapmax, ceff, deff, crate, interval )
    %STORAGEOPTIONS2 Summary of this function goes here
    %   Detailed explanation goes here
    
    storagetypes = length(instcap);
    estorage = zeros(length(feed) + 1, storagetypes);
    excess = zeros(length(feed) + 1, 1);
    
    opts = optimoptions(@fmincon, 'Display', 'off', 'MaxIterations', 250);
    
    for i = 1:length(feed)
        [estorage(i+1, :), excess(i)] = optim(feed(i), estorage(i, :), avcapmax, instcap, crate, ceff, deff, interval, opts);
        estorage(i+1, :) = estorage(i + 1, :) + estorage(i, :);
    end
    
    estorage = estorage(2:end, :);
    droppedload = trapz(excess(excess < 0)) * interval;
end

