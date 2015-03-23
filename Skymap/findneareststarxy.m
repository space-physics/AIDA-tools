function [staz,stze,stind,stmagn] = findneareststarxy(x0,y0,SkMp)
% FINDNEARESTSTARXY is a function that find the star among PSTARS that
% are closest to X0, Y0 in the sky. The star found is marked with a
% red star in the figure with the star-chart, and Azimuth, Zenith,
% Catalog Index and Magnitude of the star is returned. 
% 
% Function is called through the skymap/starcal GUI
% 
% Calling:
% [staz,stze,stind,stmagn] = findneareststarxy(x0,y0,SkMp)
% 


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

pstars = SkMp.plottstars;

fig = SkMp.figsky;
set(fig,'pointer','watch')

diff = ( 180/pi*pstars(:,6).*cos(-pstars(:,5))-x0 ).^2 + ( 180/pi*pstars(:,6).*sin(-pstars(:,5))-y0 ).^2;
[mindiff,minindex] = min(diff);

staz = pstars(minindex,1);
stze = pstars(minindex,2);
stind = pstars(minindex,3);
stmagn = pstars(minindex,4);

figure(fig)
hold on
ph = polar(-pstars(minindex,5),180/pi*pstars(minindex,6),'rh');
set(ph,'color',SkMp.prefs.cl_st_pt,'markersize',SkMp.prefs.sz_st_pt/2)
hold off
set(fig,'pointer','arrow')
