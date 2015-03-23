% plot_map
% By: Sahar Sodoudi 

% This program plots the landareas as well as the political boundary of
% countries. 
% file worldlo.mat is required!!!! 
% usage: before starting plot_map, the map axes have to be defined with worldmap 
% example:
% worldmap('europe')
% plot_map


land=shaperead('landareas','UseGeocoords',true);
setm(gca,'ffacecolor','b')   %using this line the seas are colored in blue
geoshow(land,'facecolor','w')

load worldlo.mat;
a=POline(1);
latg=a.lat;
longg=a.long;

h=plotm(latg,longg,'k-');
set(h,'linewidth',1)
