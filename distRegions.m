function [ distmat ] = distRegions(coordmatrix, regions)
    %UNTITLED3 Summary of this function goes here
    %   Detailed explanation goes here
    
    distmat = zeros(size(coordmatrix, 1));
    % distmat(1,2:end) = cell2mat(regiondata.State(1:end));
    
    for i = 1:regions
        for j = i:regions
            distmat(i, j) = distCoordinates(coordmatrix(i, 4), coordmatrix(i, 5), ...
                coordmatrix(j, 4), coordmatrix(j, 5));
        end
    end
    
end

