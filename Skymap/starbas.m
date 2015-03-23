function [e1,e2,e3] = starbas(az,el,roll)
% STARBAS calculates untit vectors of a rotated coordinate system.
% ( e2 as the optical axes )
%
% Calling:
% [e1,e2,e3] = starbas(az,el,roll)

%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%raz = az*pi/180;
%rel = el*pi/180;
%rroll = roll*pi/180;

x(1) = 1;
x(2) = 0;
x(3) = 0;

y(1) = 0;
y(2) = 1;
y(3) = 0;

z(1) = 0;
z(2) = 0;
z(3) = 1;

%rmat = abrota2(az,-el,roll);
rmat = camera_rot(az,-el,roll);

e1 = rmat*x';
e2 = rmat*y';
e3 = rmat*z';
