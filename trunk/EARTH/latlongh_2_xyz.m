function [r_out] = latlongh_2_xyz(lat0,long0,h0,lat,long,h)
% LATLONGH_2_xyz transforms the point ( LONG, LAT, H ) to (X,Y,Z)
% in a horizontal system centred at lat0, long0, h0. 
%    
% CALLING:
% [r_out] = latlongh_2_xyz(lat,long,h)
% 
% INPUT: 
%    LAT0 latitude, in degrees
%    LONG0 longiture, in degrees
%    H0 altitude, in km
%    LAT latitude, in degrees
%    LONG longiture, in degrees
%    H altitude, in km
%
% See also R_2_LLH


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



% $$$ r_out(1,:) = xx(lat*pi/180,long*pi/180,h)/NN(lat*pi/180,h);
% $$$ r_out(2,:) = yy(lat*pi/180,long*pi/180,h)/NN(lat*pi/180,h);
% $$$ r_out(3,:) = zz(lat*pi/180,long*pi/180,h)/NN(lat*pi/180,h);
% $$$ 
% $$$ r_000(1) = xx(lat0*pi/180,long0*pi/180,h0)/NN(lat0*pi/180,h0);
% $$$ r_000(2) = yy(lat0*pi/180,long0*pi/180,h0)/NN(lat0*pi/180,h0);
% $$$ r_000(3) = zz(lat0*pi/180,long0*pi/180,h0)/NN(lat0*pi/180,h0);

r_out(1,:) = XX(lat*pi/180,long*pi/180,h);
r_out(2,:) = YY(lat*pi/180,long*pi/180,h);
r_out(3,:) = ZZ(lat*pi/180,long*pi/180,h);

r_000(1) = XX(lat0*pi/180,long0*pi/180,h0);
r_000(2) = YY(lat0*pi/180,long0*pi/180,h0);
r_000(3) = ZZ(lat0*pi/180,long0*pi/180,h0);

trmtr = maketransfmtr(0,0,pi/180*lat0,pi/180*long0);

r_out(1,:) = r_out(1,:) - r_000(1);
r_out(2,:) = r_out(2,:) - r_000(2);
r_out(3,:) = r_out(3,:) - r_000(3);

r_out = trmtr'*r_out;
