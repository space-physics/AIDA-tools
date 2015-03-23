function [az,ze,apze,i_abh] = above_horizon(ra,decl,pos0,date,time0)
% ABOVE_HORIZON - finds stars above the horizon at place and time,
% (longitude,latitude, in degrees) at time TIME0 (UTC) on the day
% DATE. 
% 
% Calling:
% [possiblestars] = above_horizon(pos0,date,time0)
% 
% See also INFOV, PLOTTABLESTARS.


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%i1 = 1;


long = pos0(1);
lat = pos0(2);

[az,ze,apze] = starpos2(ra,decl,date,time0,lat,long);
[i1] = find(ze<pi/2);

az = az(i1);
ze = ze(i1);
i_abh = i1;
apze = apze(i1);
