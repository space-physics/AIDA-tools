function [localsidtime] = utc2losidt(date,utc,longitude)
% UTC2LOSIDT calculates the local sidereal time.
% 
% Calling
% [localsidtime] = utc2losidt(date,utc,longitude)
% 
% Input:
% date(1)   - the year ( 95 - 1995 )
% date(2)   - month
% date(3)   - day nr in month
% utc(1)    - hh
% utc(2)    - mm
% utc(3)    -  ss.ms
% longitude - in degrees!


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

localsidtime = utc2sidt(date,utc) + longitude/360*24;
