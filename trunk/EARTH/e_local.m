function [e1,e2,e3] = e_local(lat0,long0,alt0)
% E_LOCAL - base vectors for local Cartesian coordinate in the GEO system
% x || east , y || north, z || zenit in in (lat0,long0). 
% 
% CALLING:
% [e1,e2,e3] = e_local(lat0,long0,alt0)
%
% INPUT: 
%  LAT0  - geographic/geodetic latitude, in degrees
%  LONG0 - geographic/geodetic longiture, in degrees
%  ALT0  - altitude, in km
% 
% E_LOCAL breaks down at the geographic poles - there the longitude
% is "poorly defined" so the e1 and e2 directions become pretty
% arbitrary.

%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


f = 1/298.257;
e = (2*f-f*f)^.5;
a = 6378.137;

phi = pi/180*lat0;
Lambda = pi/180*long0;

e1(1) =  cos(Lambda);%*cos(phi);
e1(2) =  0;
e1(3) = -sin(Lambda);%*cos(phi);
e1 = e1/norm(e1);

e2(1) = -sin(Lambda)*sin(phi);
e2(2) =              cos(phi);
e2(3) = -cos(Lambda)*sin(phi);

e3 = cross(e1,e2);
