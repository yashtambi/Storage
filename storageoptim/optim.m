
clear; clc;

feed = 12;

% The dimentions of the below 5 should be the same
ceff = [0.9, 0.8, 0.8];     % Charge efficiency
deff = [0.9, 0.65, 0.95];   % Discharge efficiency
estorage = [3, 4, 4];       % Current energy content
avcapmax = [3, 4, 50];      % Max available
instcap = [4, 5, 100];      % Installed capacity
crate = [0.9, 0.8, 0.01];   % Crate max

% Add extra element for the curtailed / unserved load variable
% The value of this depends on how strongly we want the optimization
% function to consider/ignore these factors
ceff = [ceff -1];
deff = [1./deff 0.01];

% this should be passed as argument to this function
constraints = (length(estorage)*2);

A = zeros(constraints, 4);
b = zeros(1, constraints);

if feed > 0
    for i = 1:3
        A(i, i) = ceff(i);
        b(i) = avcapmax(i) - estorage(i);
    end
    for j = i+1:6
        A(j, j-i) = ceff(j-i);
        b(j) = crate(j-i) * instcap(j-i);
    end
    A(constraints, :) = [1, 1, 1, 1]; b(constraints) = feed;
    %     lb = [0, 0, 0, 0];
    %     fitnessfunc = @(x)objfunc(x, feed, ceff, deff);
    %
    %     x0 = zeros(1, 4);
    %     [X,FVAL,EXITFLAG,OUTPUT] = patternsearch(fitnessfunc,x0,A,b,[],[],lb,[],[]);
    %
%     Aeq = [];
%     beq = [];
    
    %     curtailed = feed + FVAL;
else % feed <= 0
    for i = 1:3
        A(i, i) = deff(i);
        b(i) = estorage(i);
    end
    for j = i+1:6
        A(j, j-i) = deff(j-i);
        b(j) = crate(j-i) * instcap(j-i);
    end
end

Aeq(1, :) = [1, 1, 1, 1];
beq = abs(feed);

lb = [0, 0, 0, 0];
x0 = zeros(1, 4);       % Initial values
fitnessfunc = @(x)objfunc(x, feed, ceff, deff);
[X,FVAL,EXITFLAG,OUTPUT] = patternsearch(fitnessfunc,x0,A,b,Aeq,beq,lb,[],[]);

% call optimization function