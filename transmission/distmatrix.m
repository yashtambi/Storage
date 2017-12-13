
filename = 'RegionData.xlsx';

regiondata = getregiondata();

distmat = zeros(size(regiondata, 1));
% distmat(1,2:end) = cell2mat(regiondata.State(1:end));

for i = 1:length(distmat)
    for j = 1:length(distmat)
        distmat(i, j) = distCoordinates(regiondata.Latitude(i), regiondata.Longitude(i), ...
            regiondata.Latitude(j), regiondata.Longitude(j));
    end
end