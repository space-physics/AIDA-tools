function [plstars] = plottablestars2(infovstars,magn)
% PLOTTABLESTARS2 - Selects stars in INFOVSTARS brighter than MAGN
% 
% "Private" function, called through skymap/starcal GUI.
% 
% Calling:
% [plstars] = plottablestars2(infovstars,magn)
% 
% See also INFOV, LOADSTARS.

%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

[indx] = find(infovstars(:,4)<magn);
plstars = infovstars(indx,:);
