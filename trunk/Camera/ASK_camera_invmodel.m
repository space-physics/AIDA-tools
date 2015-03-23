function [az,el] = ASK_camera_invmodel(x,y,a)
% ASK_camera_invmodel - the inverse camera model for the ASK instrument.
%  
% Calling:
%  [x,y] = ASK_camera_invmodel(x,y,a)
% Input:
%  x - Horizontal pixel coordinates [n x m]
%  y - Vertical  pixel coordinates [n x m]
%  a - optical parameters
% Output:
%  az - Azimuth (radians) [n x m]
%  el - elevation (radians) [n x m]
% 
% Adapted by B Gustavsson on 20101104 from conv_xy_ae.pro
% (Ivchenko, Whiter, Dahlgren)


%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% 
% Original comment:
%pro conv_xy_ae, x,y,az,el,a,back=back
%;
%; converts pixel coordinates to the azimuth and elevation, and back
%; using the conversion coefficients passed in "a"
%; even works with arrays!
%;
%; Inputs:
%;  x,y - Pixel coordinates
%;  a - cnv parameters
%; Outputs:
%;  ax, el - Azimuth and elevation, in radians.
%; Keywords:
%;  back - Switch inputs and outputs (except a)
%;
x0 = 1e3 *a(1);
y0 = 1e3 *a(2);
a1 = 1e-3 *a(3);
a3 = 1e-10*a(4);
ay = 1e-1 *a(5);
th = a(6);

rho = sqrt( (x-x0).^2 + (1+ay)^2.*(y-y0).^2 );
f = a1*rho + a3*rho.^3;
th_ = atan2( (1+ay)*(y-y0), x-x0);
fff = f.*cos(th+th_);
ggg = f.*sin(th+th_);

Cartesian2spherical = 1;
[az,el] = ask_conv_cart2sphere([],[],a(7),a(8),fff,ggg,Cartesian2spherical);
