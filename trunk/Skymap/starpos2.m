function [az,ze,apze] = starpos2(ra,decl,date,utc,lat,long)
% STARPOS2 gives the azimuth, zenith and apparent zenith angles
% for a sky object. It makes some good corrections for precession.
% Formulas from spherical astronomy by Robin m. Green Cambridge
% Univ. Press. 1985 
% 
% Calling:
% [az,ze,apze] = starpos2(ra,decl,date,utc,lat,long)
% Input:
% ra   - right acsention of the object in hour
% decl - declination of the object in degrees
% date - date for the observation. Date = [year month day]
% utc  - utc time for the observation. UTC = [hour minute second]
% lat  - latitude of the observer in degres
% long - longitude of the observer
% 
% Output: 
% az   - azimuth angle clockwise from north in radians
% ze   - zenith angle in radians
% apze - apparent zenith angle in radians

%   Copyright © 1999 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

rsidtime = utc2losidt( date , utc , long )/12*pi;
rra = ra'/12*pi;
rdecl = decl'/180*pi;
rlong = long/180*pi;
rlat = lat/180*pi;

t = ( date2juldate(date) - 2451545.0 ) / 36525;
d = date2juldate(date)-date2juldate([1985 01 01]);
%Cartesian coordinates on the celestial sphere
r(1,:) = cos(rdecl).*cos(rra);
r(2,:) = cos(rdecl).*sin(rra);
r(3,:) = sin(rdecl);

% rigorous precession
Za = ( .6406161 * t + .0000839 * t^2 + .0000050 * t^3 ) / 180 * pi;
za = ( .6406161 * t + .0003041 * t^2 + .0000051 * t^3 ) / 180 * pi;
ta = ( .5567530 * t + .0001185 * t^2 + .0000116 * t^3 ) / 180 * pi;

P = [-sin(Za)*sin(za) + cos(Za)*cos(za)*cos(ta),  -cos(Za)*sin(za) - sin(Za)*cos(za)*cos(ta),  -cos(za)*sin(ta);...
    sin(Za)*cos(za) + cos(Za)*sin(za)*cos(ta) ,   cos(Za)*cos(za) - sin(Za)*sin(za)*cos(ta),  -sin(za)*sin(ta);...
    cos(Za)*sin(ta)                           ,   sin(Za)*sin(ta)                          ,   cos(ta)];

N = nutation(date,utc);

rp = N*P*r;


rdecl = asin(rp(3,:));
rra = atan2(rp(2,:)./cos(rdecl),rp(1,:)./cos(rdecl));

rcorrdecl =  rdecl;

cosaz = cos ( rra );

sinaz = sin( rra );

rcorrra =    rra;

alt = asin( cos( rsidtime - rra ) .* cos( rdecl ) * cos( rlat ) + sin( rdecl ) * sin( rlat ) );
ze = pi/2 - alt';

sina = sin( rsidtime - rra ) .* cos( rdecl ) ./ cos( alt );
cosa = ( cos( rsidtime - rra ) .* cos( rdecl ) * sin ( rlat ) - ...
         sin( rdecl ) * cos( rlat ) )./ cos( alt );
az = atan2( sina' , cosa' ) + pi;

apze = refrcorr( ze );
