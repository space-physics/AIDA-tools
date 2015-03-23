function [stnXYZ,stnLongLat,trmtr] = AIDApositionize(stationNRs,central_stn_nr)
% AIDApositionize - calculate station lat-long and xyz positions 
%  for multistation auroral imaging systems.
% 
% Calling:
%  obs = AIDApositionize(stationNRs,central_stn_nr)
% Input:
%  stationNRs - array with station numbers
%  central_stn_number - the unique station identifying number of
%        the station that is the origin of the locla horizontal
%        Cartesian coordinate system.
% Output:
%  stnXYZ - station position in local horizontal coordinate
%           system centred in central-station.
%  stnLongLat - station longitude and latitude
%  trmtr - cell array with rotation matrices from "station local"
%          horizontal coordinate system to central station local
%          horizontal coordinate system.


%   Copyright � 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% Keep Stations in memory so that we only need to read all station
% information once:
persistent Stations


% If there is no StnNames field in Stations
if ~isfield(Stations,'StnNames')
  %  we have to read the station information:
  [Stations.long,Stations.lat,Stations.alts,Stations.StnNames,Stations.stnNR] = station_reader;
  
end

% For all the stationNRs 
for i1 = length(stationNRs):-1:1,
  % We search for the corresponding Stations index
  iStn = find( stationNRs(i1) == Stations.stnNR );
  % and extracts its station information, first the longitude and
  % latitude:
  if ~isempty(iStn)
    stnLongLat(i1,:) = [Stations.long(iStn),Stations.lat(iStn)];
  end
  % If we have told AIDApositionize which station number to use for
  % central station - for a horizontal coordinate system:
  if ~isempty(iStn) && nargin > 1
    % Then use it
    iCStn = find( central_stn_nr == Stations.stnNR );
    if ~isempty(iCStn)
      % To calculate the cartesian coordinates of stationNRs
      [x,y,z] = makenlcpos(Stations.lat(iCStn),...
                           Stations.long(iCStn),...
                           Stations.alts(iCStn),...
                           Stations.lat(iStn),...
                           Stations.long(iStn),...
                           Stations.alts(iStn));
      stnXYZ(i1,:) = [x,y,z];
      % And the rotation matrix between its local horizontal
      % coordinates and the central-station horizontal coordinates:
      trmtr{i1} = maketransfmtr(Stations.lat(iCStn),...
                                Stations.long(iCStn),...
                                Stations.lat(iStn),...
                                Stations.long(iStn),...
                                1);
    end
  end
  
end
