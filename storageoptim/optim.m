function [eval, excess] = optim(feed, estorage, avcapmax, instcap, crate, ...
        ceff, deff, interval, opts)
    sttypes = length(estorage);
    
    % this should be passed as argument to this function
    constraints = (sttypes * 2);
    
    % Add extra element for the curtailed / unserved load variable
    % The value of this depends on how strongly we want the optimization
    % function to consider/ignore these factors
    ceff = [ceff; -1];
    deff = [1./deff; 100];
    
    A = zeros(constraints, sttypes+1);
    b = zeros(1, constraints);
    
    if feed > 0
        eff = ceff;
        for i = 1:sttypes
            A(i, i) = eff(i);
            b(i) = avcapmax(i) - estorage(i);
        end
    else
        eff = deff;
        for i = 1:sttypes
            A(i, i) = eff(i);
            b(i) = estorage(i);
        end
    end
    
    for i = sttypes+1: sttypes*2
        A(i, i-sttypes) = eff(i-sttypes);
        b(i) = crate(i-sttypes) * instcap(i-sttypes);
    end
    
    Aeq(1, :) = [1, 1, 1, 1];
    beq = abs(feed);
    
    lb = zeros(1, sttypes + 1);
    x0 = zeros(1, sttypes + 1);       % Initial values
    fcn = @(x)objfunc(x, feed, eff);
    
    eval = fmincon(fcn, x0, A, b, Aeq, beq, lb, [], [], opts);
    
    excess = eval(end);
    % Actual energy withdrawn (-ve) / deposited (+ve) in the storage types
    eval = sign(feed) .* eval(1:end-1) .* eff(1:end-1)' .* interval;
    eval(abs(eval)<1e-4) = 0;
end

% call optimization function