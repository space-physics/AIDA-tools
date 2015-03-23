function [az,alt,ze] = solar_pos(date,time,long,lat)
% Unfinished! SOLAR_POS - Get the sky position of the sun
% 
% Calling:
%  [az,alt,ze] = solar_pos(date,time,long,lat)
% 
% Input:
% DATE - date [Y, M, D]
% TIME - time [HH, MM, SS] (UT)
% LONG - longitude
% LAT  - latitude
% 


%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

UT = time(1) + time(2)/60 + time(3)/3600;

Z = [-.5 30.5 58.5 89.5 119.5 150.5 211.5 242.5 272.5 303.5 333.5];

Y = date(1) - 1900;
if Y/4 == floor(Y/4)
  Z(1:2) = Z(1:2)-1;
end
D = floor(365.25 * Y) + Z(date(2)) + date(3) + UT/24;
T = D/36525;

L = pi/180*(279.697 + 36000.769 * T); % Mean longitud of sun

M = pi/180*(358.476 + 35999.050 * T);  % Mean anomaly of sun
epsilon = pi/180*(23.452 - 0.013 * T);        % approximate obliquity

lambda = L + pi/180*((1.919 - 0.005 * T) * sin(M) + 0.020 * sin(2*M)); % ecliptic longitude
alpha = atan2(tan(lambda),cos(epsilon));
dec = asin(sin(lambda) * sin(epsilon));

HA = L - alpha + pi + 15/180*pi * UT + long;

alt = asin(sin(lat)*sin(dec) + cos(lat)*cos(dec)*cos(HA));
az = atan2( sin(HA), cos(HA)*sin(lat) - tan(dec)*cos(lat) );
ze = pi-alt;
