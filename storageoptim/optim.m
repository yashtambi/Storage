
function [f] = optim(feed, estorage, avcapmax, instcap, crate, ceff, deff, interval)
sttypes = length(estorage);

% this should be passed as argument to this function
constraints = (sttypes * 2);

% Add extra element for the curtailed / unserved load variable
% The value of this depends on how strongly we want the optimization
% function to consider/ignore these factors
ceff = [ceff -1];
deff = [1./deff 100];

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
fitnessfunc = @(x)objfunc(x, feed, eff);

[X,FVAL,EXITFLAG,OUTPUT] = patternsearch(fitnessfunc, x0, A, b, Aeq, beq, lb, [], []);

%{
    Todo: 
        1. Changing the output (values of dist) for actual energy withdrawn
        / deposited in the storage, since this function only gives the
        distribution of feed
        2. FVAL to show the curtailed / unserved load
        3. Multiplying results of (1) by interval to get the total energy
        withdrawn / deposited for the duration
%}

end

% call optimization function