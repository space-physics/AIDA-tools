function [r_out] = latlongh_2_r(lat,long,h)
% LATLONGH_2_R transforms the point ( LONG, LAT, H ) to (X,Y,Z)
% in an earth centred horizontal system (GEO). 
%    
% CALLING:
% [r_out] = r0_latlongh(lat,long,h)
% 
% INPUT: 
%    LAT0 latitude, in degrees
%    LONG0 longiture, in degrees
%    ALT0 altitude, in km
%
% See also R_2_LLH


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

r_out(1) = XX(lat*pi/180,long*pi/180,h);
r_out(2) = YY(lat*pi/180,long*pi/180,h);
r_out(3) = ZZ(lat*pi/180,long*pi/180,h);
