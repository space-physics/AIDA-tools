function obs = AIDAstationize(obs,central_stn_nr)
% AIDAstationize - calculate station lat-long and xyz positions 
%  for multistation auroral imaging systems.
% 
% Calling:
%  obs = AIDAstationize(obs,central_stn_nr)
% Input:
%  obs - struct with image meta-data, used here is obs.station,
%        which should be a the unique station identifying number
%  central_stn_number - the unique station identifying number of
%        the station that is the origin of the locla horizontal
%        Cartesian coordinate system.
% Output:
%  obs - struct with meta-data, this function adds fields: 
%        longlat with longitude and latitude of station (degrees)
%        xyz - station position in local horizontal coordinate
%              system centred in central-station.
%        trmtr - rotation matrix from "station local" horizontal
%              coordinate system to central station local
%              horizontal coordinate system.
%        pos - same as longlat, THIS FIELD IS BEING MADE OBSOLETE,
%              CHANGE IN YOUR CODE TO AVOID ERRORS WHEN THIS
%              REMOVED 
% 

% Copyright Bjorn Gustavsson 20100715



% Keep Stations in memory so that we only need to read all station
% information once:
persistent Stations

% If there is no StnNames field in Stations
if ~isfield(Stations,'StnNames')
  
  %  we have to read the station information:
  [Stations.long,Stations.lat,Stations.alts,Stations.StnNames,Stations.stnNR] = station_reader;
  
end

% For the current stationNR
iStn = find( obs.station == Stations.stnNR );

% Determine the longitude and latitude of the current station:
if ~isempty(iStn)
  obs.longlat = [Stations.long(iStn),Stations.lat(iStn)];
  obs.pos = obs.longlat;
end

% If we have told AIDAstationize which station number to use for
% central station - for a horizontal coordinate system:
if ~isempty(iStn) && nargin > 1
  % then search for the corresponding Stations index
  iCStn = find( central_stn_nr == Stations.stnNR );
  if ~isempty(iCStn)
    % and use it to calculate the cartesian coordinates of stationNRs
    [x,y,z] = makenlcpos(Stations.lat(iCStn),...
                         Stations.long(iCStn),...
                         Stations.alts(iCStn),...
                         Stations.lat(iStn),...
                         Stations.long(iStn),...
                         Stations.alts(iStn));
    obs.xyz = [x,y,z];
    % And the rotation matrix between its local horizontal
    % coordinates and the central-station horizontal coordinates:
    [obs.trmtr] = maketransfmtr(Stations.lat(iCStn),...
                                Stations.long(iCStn),...
                                Stations.lat(iStn),...
                                Stations.long(iStn),...
                                1);
  end
end
