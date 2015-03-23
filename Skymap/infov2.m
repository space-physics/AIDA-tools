function [infovstars,SkMp] = infov2(possiblestars,az0,ze0,rot0,fov,SkMp)
% INFOV2 finds stars inside a specified field of view
% specified by AZ0, ZE0, ROT0 (degrees) and FOV (radians). 
% "Private" function called through the skymap/starcal GUI. Not
% much use for user to call this function manually
% 
% Calling:
% [infovstars] = infov2(possiblestars,az0,ze0,rot0,fov)
% 
% See also PLOTTABLESTARS, LOADSTARS.


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%imax = size( possiblestars );

[e1,e2,e3] = starbas(az0,ze0,rot0);

SkMp.e1 = e1;
SkMp.e2 = e2;
SkMp.e3 = e3;

az = possiblestars(:,1);
el = pi/2 - possiblestars(:,2);
[phi,theta] = starbestaemft2(180*az/pi,180*el/pi,e1,e2,e3);

fov_scale = 2-isempty(SkMp.img);
[indx] = find(theta<abs(fov)*fov_scale^.5);
infovstars = possiblestars(indx,:);
infovstars(:,8) = possiblestars(indx,6);
infovstars(:,5) = phi(indx)';
infovstars(:,6) = theta(indx)';
