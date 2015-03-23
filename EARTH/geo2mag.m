function [mLong,mLat] = geo2mag(Long,Lat,longMpole,latMpole)
% GEO2MAG - Convert from geographic to geomagnetic coordinates
% EXPLANATION:
%   Converts from GEOGRAPHIC (latitude,longitude) to GEOMAGNETIC (latitude, 
%   longitude).   (Altitude remains the same)
%
%       Latitudes and longitudes are expressed in degrees.
% 
% Calling:
%  [mLong,mLat] = geo2mag(Long,Lat)
% Input:
%  Long - geographic longitude (degrees), double array [n1 x n2 x
%          ... x nJ]
%  Lat  - geographic latitude (degrees), double array [n1 x n2 x... x nI]
%  longMpole - geographic longitude of magnetic pole (degrees),
%              optional defaults to 72.21�W [2010]
%  latMpole  - geographic longitude of magnetic pole (degrees),
%              optional defaults to 80.08� [2010]
% Output:
%  mLong - magnetic longitude (degrees), double array same size
%          as Long and Lat
%  mLat  - magnetic longitude (degrees), double array same size
%          as Long and Lat
%
% Example:
% % from magnetic south pole Geo to Mag coordinates
%  [mLong,mLat] = geo2mag95(288.59,79.2)
%      mLong =  0, mLat = 90
% 
% Translated from IDL-function by Pascal Saint-Hilaire
% (Saint-Hilaire@astro.phys.ethz.ch),  


% If no coordinates for magnetic pole given set it to 2010
% 'constants'... 
% North Magnetic Dipole 2010: 72.21�W longitude and 80.08�
if nargin < 3 || isempty(longMpole)
  Dlong = -72.21;% longitude (in degrees) of Earth's magnetic south
                 % pole (2010) which is near the geographic north
                 % pole...) 
else
  Dlong = longMpole;
end
if nargin < 4 || isempty(latMpole)
  Dlat  = 80.08; % latitude (in degrees) of magnetic pole (2010)
else
  Dlat = latMpole;
end


% first convert to radians
Dlong = Dlong* pi/180;
Dlat  = Dlat * pi/180;

glat = Lat(:)'*pi/180;
glon = Long(:)'*pi/180;

% convert to rectangular coordinates
%  X-axis: defined by the vector going from Earth's center towards
%          the intersection of the equator and Greenwitch's meridian.
%  Z-axis: axis of the geographic poles
%  Y-axis: defined by Y = Z^X
x = cos(glat).*cos(glon);
y = cos(glat).*sin(glon);
z = sin(glat);


% Compute 1st rotation matrix : rotation around plane of the equator,
% from the Greenwich meridian to the meridian containing the magnetic
% dipole pole.
geolong2maglong = zeros(3,3);
geolong2maglong(1,1) =  cos(Dlong);
geolong2maglong(1,2) =  sin(Dlong);
geolong2maglong(2,1) = -sin(Dlong);
geolong2maglong(2,2) =  cos(Dlong);
geolong2maglong(3,3) =  1;

out = geolong2maglong * [x;y;z];

% Second rotation : in the plane of the current meridian from geographic
% pole to magnetic dipole pole.
tomaglat = zeros(3,3);
tomaglat(1,1) =  cos(pi/2-Dlat); % !DPI/2 ???
tomaglat(1,3) = -sin(pi/2-Dlat);
tomaglat(3,1) =  sin(pi/2-Dlat);
tomaglat(3,3) =  cos(pi/2-Dlat);
tomaglat(2,2) = 1;
out =  tomaglat * out;

% Pre-allocate the outputs
mLong = Long;
mLat = Lat;
% convert back to latitude, longitude and altitude
mLat(:) = atan2(out(3,:),sqrt(out(1,:).^2+out(2,:).^2));
mLat = mLat*180/pi;
mLong(:) = atan2(out(2,:),out(1,:));
mLong = mLong*180/pi;

%==============================================================================
