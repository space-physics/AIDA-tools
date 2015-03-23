%% Example script for projecting an All-sky image to lat-long grid

%%
% It is assumed that a geometric calibration has been done with
% AIDA-tools starcal function giving optical parameters describing
% the geometric character and rotation of the camera (or any other
% function giving the consistent parameters). The optical
% parameters are expected to be in a variable: optpRamfjordNIPR here.
% 

%% Dependencies:
% * This script uses several functions from AIDA_tools
% * Further the script uses functions from the m_map toolbox
%   available from: http://www.eos.ubc.ca/~rich/map.html

%% Geographi coordinates of Ramfjord:
Ramfjord_long = 19 + 13/60 + 38/3600;
Ramfjord_lat = 69 + 35/60 + 11/3600;
optpRamfjordNIPR = [-0.71846, -0.7096, -1.1126, 0.6338, 0.91097, 0.0020362,0.016534, 0.47431, 2, 0];

%% Magnetic Long-lat of "Ramfjord"
[R_mlong2,R_mlat2] = geo2mag95(Ramfjord_long,Ramfjord_lat);
%% Geomagnetic meridian coordinates for 4-degree wide arc:
[K_mlong,K_mlat] = meshgrid(R_mlong2,R_mlat2+linspace(-2,2,501));
%% The geographic coordinates of that magnetic-meridian-arc:
[K_glong,K_glat] = mag2geo95(K_mlong,K_mlat);
%% Coordinates of that arc in the Ramfjord-local horizontal
%  coordinate system (at 105 km altitude):
[r_out] = latlongh_2_xyz(Ramfjord_lat,Ramfjord_long,0.15,K_glat(:),K_glong(:),105);
%% Keogram for the points along that
[Keo,exptimes,Tstrs,filters] = imgs_rgb_keograms_r3(fname,[0 0 0],r_out,optpRamfjordNIPR,po);
%%
% This is a very short keogram since there is only 1 image...
subplot(2,1,1)
%%
% Plot the arc:
plot3(r_out(1,:),r_out(2,:),r_out(3,:),'*-')
grid on
subplot(2,1,2)
%% 
% Simple display of image:
imagesc(uint8(Keo))
