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


Ramfjord_long = 19 + 13/60 + 38/3600;
Ramfjord_lat = 69 + 35/60 + 11/3600;
optpRamfjordNIPR = [-0.71846, -0.7096, -1.1126, 0.6338, 0.91097, 0.0020362,0.016534, 0.47431, 2, 0];

%% Define a geographic lat-long grid:
[Long,Lat] = meshgrid(linspace(7,31,500),linspace(65,74,506));
%% Project an ASC-image to that long-lat grid at 105 km of altitude:
Im_projLL = inv_proj_img_ll(d,...
                            optpRamfjordNIPR(9),optpRamfjordNIPR,...
                            Ramfjord_lat,Ramfjord_long,0.15,...
                            Lat,Long,105,80);

%% Prepare for geomagnetic grid:
%% Convert the geographic grid to geomagnetic:
[mLong,mLat] = geo2mag95(Long,Lat);
[mLong,mLat] = geo2mag(Long,Lat);

%% Plot the projected image on the 2 grids:
subplot(1,2,2)
m_coord('IGRF2000-geomagnetic'); % Now assume that values are in geomagnetic
m_proj('lambert','long',[100 135],'lat',[60 80]);
m_pcolor(mLong,mLat,Im_projLL),shading flat
% m_coast
try
  m_usercoast('Lambert-0-35E-65-80N','color','k','linewidth',1);
catch
  m_gshhs_i('save','Lambert-0-35E-65-80N');
  m_usercoast('Lambert-0-35E-65-80N','color','k','linewidth',1);
end
m_grid('box','fancy','tickdir','in');
subplot(1,2,1)
m_coord('geographic'); % Define all in geographic,,,   
m_proj('lambert','long',[7 31],'lat',[65 74]);   
m_pcolor(Long,Lat,Im_projLL),shading flat
m_coast
m_grid('box','fancy','tickdir','in');

%% If desired print figure to file:
% print -depsc2 -painters Geo-n-Mag-mappings.eps
