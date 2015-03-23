function [az,ze,apze] = moonpos(date,utc,lat,long)
% MOONPOS calculates lunar azimuth, zenith and apparent zenith angles
%  Is a wrapper to LunarAzEl that does the actual calculations of
%  the moon position.
% 
% Calling:
% [az,ze,apze] = moonpos(date,utc,lat,long)
% Input:
%  date - date for the observation. Date = [year month day]
%  utc  - utc time for the observation. UTC = [hour minute second]
%  lat  - latitude of the observer in degres
%  long - longitude of the observer
% 
% Output: 
%  az   - azimuth angle clockwise from north in radians
%  ze   - zenith angle in radians
%  apze - apparent zenith angle in radians

%   Copyright © 1999 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

timestring = datestr([date, utc],'yyyy/mm/dd HH:MM:SS');

[Az,El] = LunarAzEl(timestring,lat,lon,0);

az = Az*pi/180;
ze = (90-el)*pi/180;
apze = refrcorr(ze);
