function [gLong,gLat] = mag2geo(mLong,mLat,longMpole,latMpole)
% MAG2GEO - Convert from geomagnetic to geographic coordinates
%  Converts from GEOMAGNETIC (latitude,longitude) to GEOGRAPHIC
%  (latitude, longitude), (while altitude remains the same)
%
% Calling:
%  [gLong,gLat] = mag2geo95(mLong,mLat,longMpole,latMpole)
% Input:
%  mLong - magnetic longitude (degrees), double array [n1 x n2 x
%          ... x nJ]
%  mLat  - magnetic latitude (degrees), double array [n1 x n2 x... x nI]
%  longMpole - geographic longitude of magnetic pole (degrees),
%              optional defaults to 72.21�W [2010]
%  latMpole  - geographic longitude of magnetic pole (degrees),
%              optional defaults to 80.08� [2010]
% Output:
%  gLong - geographic longitude (degrees), double array same size
%          as mLong and mLat
%  gLat  - geographic longitude (degrees), double array same size
%          as mLong and mLat
% Example:
%   [MPlong,MPlat] = mag2geo95(0,90)  % coordinates of magnetic south pole
%      MPlong =  -71.409990    MPlat = 79.300000
%
% Translated from mag2geo.pro written by Pascal Saint-Hilaire
% (Saint-Hilaire@astro.phys.ethz.ch)

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

% convert first to radians
Dlong = Dlong*pi/180;
Dlat = Dlat*pi/180;

mlat = mLat(:)'*pi/180;
mlon = mLong(:)'*pi/180;

%convert to rectangular coordinates
% X-axis: defined by the vector going from Earth's center towards
%         the intersection of the equator and Greenwich's meridian.
% Z-axis: axis of the geographic poles
% Y-axis: defined by Y = Z^X
x = cos(mlat).*cos(mlon);
y = cos(mlat).*sin(mlon);
z = sin(mlat);

%First rotation : in the plane of the current meridian from magnetic 
%pole to geographic pole.
togeolat = zeros(3,3);
togeolat(1,1) =  cos(pi/2-Dlat);
togeolat(1,3) =  sin(pi/2-Dlat);
togeolat(3,1) = -sin(pi/2-Dlat);
togeolat(3,3) =  cos(pi/2-Dlat);
togeolat(2,2) =  1;
out =  togeolat * [x;y;z];

%Second rotation matrix : rotation around plane of the equator, from
%the meridian containing the magnetic poles to the Greenwich meridian.
maglong2geolong = zeros(3,3);
maglong2geolong(1,1) =  cos(Dlong);
maglong2geolong(1,2) = -sin(Dlong);
maglong2geolong(2,1) =  sin(Dlong);
maglong2geolong(2,2) =  cos(Dlong);
maglong2geolong(3,3) =  1;

out = maglong2geolong * out;


gLong = mLong;
gLat  = mLat;

%convert back to latitude, longitude and altitude
gLat(:) = atan2(out(3,:),sqrt(out(1,:).^2+out(2,:).^2));
gLat = gLat*180./pi;
gLong(:) = atan2(out(2,:),out(1,:));
gLong = gLong*180./pi;
