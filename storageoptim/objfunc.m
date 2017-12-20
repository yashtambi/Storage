function [ f ] = objfunc(dist, feed, ceff, deff )
    %OBJFUNC This function is the objective function for optimizing the
    %amount of energy actually stored in the storage, or minimize the
    %amount of actual energy withdrawn from each source to serve a givin
    %load
    % Arguments:
    % dist: distribution amongst each source
    % feed: energy deficit at the point
    % ceff: charge efficiency for each storage type
    % deff: discharge efficiency for each storage type
    
    if feed > 0
        % Actual energy stored in the battery
        % This needs to be maximized
        f = -1 * sum(ceff .* dist);
    else
        % Actual energy withdrawn from the storage to supply the load
        % This needs to be minimized
        f = sum(dist .* deff);      
    end
    
end

