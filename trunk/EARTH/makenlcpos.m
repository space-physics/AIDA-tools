function [x,y,z] = makenlcpos(lat0,long0,alt0,lat,long,alt)
% MAKENLCPOS transforms the positions (LAT, LONG, ALT) to (X,Y,Z)
% in a Cartesian coordinate system x || east , y || north, z ||
% zenit centered in (lat0,long0) at altitude ALT0 above sea level. 
% 
% CALLING:
% [x,y,z] = makenlcpos(lat0,long0,alt0,lat,long,alt)
% 
% INPUT: 
%    LAT0 latitude of reference point (origin of coordinates), in degrees
%    LONG0 longiture,of reference point (origin of coordinates) in degrees
%    ALT0 altitude,  of reference point (origin of coordinates) in km
%    LAT latitude, in degrees
%    LONG longiture, in degrees
%    ALT altitude, in km



%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


[x,y,z] = llh_to_local_coord(lat0,long0,alt0,lat,long,alt);

% $$$ f = 1/298.257;
% $$$ e = (2*f-f*f).^.5;
% $$$ a = 6378.137;
% $$$ 
% $$$ phi(1,:) = pi/180*lat0*ones(size(lat));
% $$$ lambda(1,:) = pi/180*long0*ones(size(long));
% $$$ phi(2,:) = pi/180*lat;
% $$$ lambda(2,:) = pi/180*long;
% $$$ 
% $$$ 
% $$$ e1(1,:) = cos(lambda(1,:)).*cos(phi(1,:)).*(alt0 + a./(1 - e^2*sin(phi(1,:))).^(1/2));
% $$$ e1(2,:) = 0;
% $$$ e1(3,:) = -cos(phi(1,:)).*sin(lambda(1,:)).*(alt0 + a./(1 - e^2*sin(phi(1,:))).^(1/2));
% $$$ 
% $$$ e1 = e1/norm(e1);%*e1')^.5;
% $$$ 
% $$$ 
% $$$ e2(1,:) = (a*e^2*cos(phi(1,:)).^2.*sin(lambda(1,:)))./(2*(1 - e^2*sin(phi(1,:))).^(3/2)) - sin(lambda(1,:)).*sin(phi(1,:)).*(alt0 + a./(1 - e^2*sin(phi(1,:))).^(1/2));
% $$$ e2(2,:) = cos(phi(1,:)).*(alt0 - (a*(e^2 - 1))./(1 - e^2*sin(phi(1,:))).^(1/2)) - (a*e^2*cos(phi(1,:)).*sin(phi(1,:)).*(e^2 - 1))./(2*(1 - e^2*sin(phi(1,:))).^(3/2));
% $$$ e2(3,:) =(a*e^2*cos(lambda(1,:)).*cos(phi(1,:)).^2)./(2*(1 - e^2*sin(phi(1,:))).^(3/2)) - cos(lambda(1,:)).*sin(phi(1,:)).*(alt0 + a./(1 - e^2*sin(phi(1,:))).^(1/2));
% $$$ 
% $$$ e2 = e2/norm(e2);%*e2')^.5;
% $$$ 
% $$$ e3 = cross(e1,e2);
% $$$ 
% $$$ ro(1,:) = xx(phi(1,:),lambda(1,:),alt0);
% $$$ ro(2,:) = yy(phi(1,:),lambda(1,:),alt0);
% $$$ ro(3,:) = zz(phi(1,:),lambda(1,:),alt0);
% $$$ 
% $$$ r(1,:) = xx(phi(2,:),lambda(2,:),alt');
% $$$ r(2,:) = yy(phi(2,:),lambda(2,:),alt');
% $$$ r(3,:) = zz(phi(2,:),lambda(2,:),alt');
% $$$ 
% $$$ r_ro = r - ro;
% $$$ 
% $$$ x = dot(r_ro,e1);
% $$$ y = dot(r_ro,e2);
% $$$ z = dot(r_ro,e3);
% $$$ 
