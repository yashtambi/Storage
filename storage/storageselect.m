function [out, val] = storageselect (feed, estorage, avcapacity, storageoptions)
    
    efficiency = storageoptions(:,2);
    cratemax = storageoptions(:,3);
    limit = storageoptions(:, 6);
    
    if feed >= 0
        etransfer = efficiency.* ...
            min(feed, cratemax .* avcapacity ./ limit);
    elseif feed < 0
        etransfer = feed ./ efficiency;
        limitexceed = abs(etransfer) >  (cratemax .* avcapacity ./ limit);
        limitexceed = limitexceed ~= 0;
        etransfer (limitexceed) = -inf;
    end
    
    estorage = estorage + etransfer';
    etransfer(estorage < 0) = 0;
    etransfer(estorage > avcapacity) = 0;
    
    val = max(etransfer);
    out = find(etransfer == val);
    out = out(1);
end