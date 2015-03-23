function [trmtr] = maketransfmtr(lat0,long0,lat,long,already_degrees)
% MAKETRANSFMTR - the transformation rotation matrixes
% from the local coordinate system in LAT, LONG to the local
% coordinate system in LAT0, LONG0, 
% OBS! default Input in radians!!!
%
% CALLING:
% [trmtr] = maketransfmtr(lat0,long0,lat,long)
% [trmtr] = maketransfmtr(lat0,long0,lat,long,already_degrees)
% 
% INPUT:
%    LAT0 latitude of reference point (origin of coordinates)
%    LONG0 longiture,of reference point (origin of coordinates)
%    LAT latitude,
%    LONG longiture,
%    DEGS_2_RADIANS - flag to switch to conversion from input in
%                     degrees 
% ANGLES in _RADIANS BY DEFAULT!!!

%   Copyright � 20000323 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin>4 && already_degrees
  % Do no conversion from radians to degrees!
  %phi0 = lat0;
  %Lambda0 = long0;
  %phi = lat;
  %Lambda = long;
else
  lat0 = lat0*180/pi;
  long0 = long0*180/pi;
  lat = lat*180/pi;
  long = long*180/pi;
  
  %phi0 = lat0;
  %Lambda0 = long0;
  %phi = lat;
  %Lambda = long;
end  

[e1,e2,e3]    = e_local(lat0,long0,0);
[e1p,e2p,e3p] = e_local(lat,long,0);

trmtr(1,1) = dot(e1p,e1);
trmtr(1,2) = dot(e2p,e1);
trmtr(1,3) = dot(e3p,e1);
trmtr(2,1) = dot(e1p,e2);
trmtr(2,2) = dot(e2p,e2);
trmtr(2,3) = dot(e3p,e2);
trmtr(3,1) = dot(e1p,e3);
trmtr(3,2) = dot(e2p,e3);
trmtr(3,3) = dot(e3p,e3);
