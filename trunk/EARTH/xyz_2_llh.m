function [long,lat,h] = xyz_2_llh(lat0,long0,h0,r)
% XYZ_2_LLH transforms X,Y,Z in an lat0,long0 centred horizontal system
% to ( LONG, LAT, H ).
%    
% Calling:
% [long,lat,h] = xyz_2_llh(lat0,long0,h0,r)
% 
% See also LATLONGH_2_R


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r0 = latlongh_2_r(lat0,long0,h0);

[e1,e2,e3] = e_local(lat0,long0,h0);
trmtr = [e1',e2',e3'];
rtmp = (trmtr*r')';

rtmp(:,1) = rtmp(:,1) + r0(1);
rtmp(:,2) = rtmp(:,2) + r0(2);
rtmp(:,3) = rtmp(:,3) + r0(3);

[long,lat,h] = r_2_llh(rtmp);
long = long*180/pi;
lat = lat*180/pi;
