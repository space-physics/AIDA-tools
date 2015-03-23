function [x,y,z] = llh_to_local_coord(lat0,long0,alt0,lat,long,alt)
% LLH_TO_LOCAL_COORD transforms the positions (LAT, LONG, ALT) to (X,Y,Z)
% in a Cartesian coordinate system x || east , y || north, z ||
% zenit centered in (lat0,long0) at altitude ALT0 above sea level. 
% 
% CALLING:
% [x,y,z] = llh_to_local_coord(lat0,long0,alt0,lat,long,alt)
% 
% INPUT: 
%    LAT0 latitude of reference point (origin of coordinates), in degrees
%    LONG0 longiture,of reference point (origin of coordinates) in degrees
%    ALT0 altitude,  of reference point (origin of coordinates) in km
%    LAT latitude, in degrees
%    LONG longiture, in degrees
%    ALT altitude, in km
% OUTPUT:
%  X - Horisontal east distance from (lat0,long0,alt0) (km)
%  Y - Horisontal north distance from (lat0,long0,alt0) (km)
%  Z - Horisontal altitude above (lat0,long0,alt0) (km)


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
% f = 1/298.257;
% e = (2*f-f*f).^.5;
% a = 6378.137;


phi0 = pi/180*lat0*ones(size(lat));
Lambda0 = pi/180*long0*ones(size(long));
phi = pi/180*lat;
Lambda = pi/180*long;


[e1,e2,e3] = e_local(lat0,long0,0);

ro(1,:) = XX(phi0,Lambda0,alt0);
ro(2,:) = YY(phi0,Lambda0,alt0);
ro(3,:) = ZZ(phi0,Lambda0,alt0);

r(1,:) = XX(phi,Lambda,alt);
r(2,:) = YY(phi,Lambda,alt);
r(3,:) = ZZ(phi,Lambda,alt);

r_ro = r - ro;

x = dot(r_ro,e1);
y = dot(r_ro,e2);
z = dot(r_ro,e3);
