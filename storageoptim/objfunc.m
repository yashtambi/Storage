function [ f ] = objfunc(dist, feed, eff)
    %OBJFUNC This function is the objective function for optimizing the
    %amount of energy actually stored in the storage, or minimize the
    %amount of actual energy withdrawn from each source to serve a givin
    %load
    % Arguments:
    % dist: distribution amongst each source
    % feed: energy deficit at the point
    % eff: efficiency for each storage type (charge / discharge)
    
    f = -1 * sign(feed) * sum(eff .* dist);
end

