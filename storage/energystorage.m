
function [ estorage, unservedload, storagecost ] = energystorage3( feed, storageoptions, t, capacity, distribution )
    %ENERGYSTORAGE
    % feed: total demand deficit (supply - demand)
    % storageoptions: xlsread of 'storageoptions.xlsx' file
    % t: time
    % capacity: array of capacity allocation for each storage type (in TWh)
    % distribution: array of fraction of deficit to be allocated to each
    %               storage type (Note: sum should be <= 1)
    % 
    % Outputs:
    % estorage: Cumulative energy content waveform
    % unservedload: Total energy dificit / excess (+ve if excess)
    % storagecost: total cost of installed capacity (as per capacity)
    
    
    if sum(distribution) > 1
        error('Energy cannot be made out of thin air!')
    end
    
    noptions = size(storageoptions);
    noptions = noptions(1);
    
    if (length(capacity) ~= noptions) || (length(distribution) ~= noptions)
        error('Incomplete arrays for either capacity / distributions');
    end
    
    interval = t(2) - t(1);                       % Spacing
    estorage = zeros(noptions, length(feed)+1);   % Filtered output
    capacity = capacity .* 1e6;
    avcapacity = zeros(1, noptions);              % Available Capacity
    
    for j = 1:noptions
        cratemax = storageoptions(j, 3);
        if capacity(j) > storageoptions(j, 4)
            capacity(j) = storageoptions(j, 4);
        end
        avcapacity(j) = capacity(j)*storageoptions(j, 6);
        
        % This for loop charges / discharges the storage type as per input feed
        for i = 1:length(feed)
            estorage(j, i+1) = estorage(j, i) + ...
                storageoptions(1, 2) * (sign(feed(i)) * interval * ...
                min(cratemax * avcapacity(j), abs(distribution(j) * feed(i))));
            if estorage(j, i+1) <= 0
                estorage(j, i+1) = 0;
            elseif estorage(j, i+1) >= avcapacity(j)
                estorage(j, i+1) = avcapacity(j);
            end
        end
        
        % Apply ramping constraints
        estorage(j, 2:end) = sfilter(estorage(j, 2:end), t, storageoptions(1, 5));
    end
    
    estorage = estorage(:, 2:end);      % Remove the extra 1st element
    estorage = sum(estorage, 1);        % Sum of all storage available
    
    % Total unserved load (0 if none, -ve if unserved)
    unservedload = estorage(end) + (trapz(feed(estorage==0))*interval);
    
    if nargout > 2      % Total cost of installed capacity
        storagecost = sum(capacity .* storageoptions(:,1));
    end
end