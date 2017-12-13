function [ dist_m ] = distCoordinates( lat1, lon1, lat2, lon2 )
    % Returns the distance between the input coordinates
    %   The coordinates must be in degrees
  earthRadiusm = 6371000;

  dLat = degtorad(lat2-lat1);
  dLon = degtorad(lon2-lon1);

  lat1 = degtorad(lat1);
  lat2 = degtorad(lat2);

  a = sin(dLat/2) * sin(dLat/2) + ...
          sin(dLon/2) * sin(dLon/2) * cos(lat1) * cos(lat2); 
  c = 2 * atan2(sqrt(a), sqrt(1-a)); 
  
  dist_m = earthRadiusm * c;
end

