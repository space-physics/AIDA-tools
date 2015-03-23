function [x,y] = ASK_camera_model(az,el,a)
% ASK_camera_model - the camera model for the ASK instrument.
%  
% Calling:
%  [x,y] = ASK_camera_model(az,el,a)
% Input:
%  az - Azimuth (radians) [n x m]
%  el - elevation (radians) [n x m]
%  a - optical parameters
% Output:
%  x - Horizontal pixel coordinates [n x m]
%  y - Vertical  pixel coordinates [n x m]
% 
% Adapted by B Gustavsson on 20101104 from conv_xy_ae.pro
% (Ivchenko, Whiter, Dahlgren)

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
%;  az, el - Azimuth and elevation, in radians.
%; Keywords:
%;  back - Switch inputs and outputs (except a)
%;
x0 = 1e3 *a(1);
y0 = 1e3 *a(2);
a1 = 1e-3 *a(3);
a3 = 1e-10*a(4);
ay = 1e-1 *a(5);
th = a(6);

%[fff,ggg] = conv_sc(az,el,a(7),a(8),fff,ggg);
[fff,ggg] = ask_conv_cart2sphere(az,el,a(7),a(8));
f_ = sqrt(fff.*fff + ggg.*ggg);
rho = f_/a1;
%for i = 0,7 do rho = f_/(a1+a3*rho*rho)
for i = 0:7
  rho = f_./(a1+a3*rho.*rho);
end
xsi = rho.*cos(atan2(ggg,fff)-th);
eta = rho.*sin(atan2(ggg,fff)-th);
x = x0+xsi;
y = y0+eta/(1+ay);
end
%%% TODO: find out which variables will be arrays et all...
