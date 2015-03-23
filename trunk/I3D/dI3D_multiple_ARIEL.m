function [V_em] = dI3D_multiple_ARIEL(I0_r0_dr,X,Y,Z,dt,tau,mag_ze)
% dI3D_multiple - multiple 3-D generalized Gaussians
% DI3D_multiple gives a sum of 3-D generalized Gaussians with
% parameters from I0_r0_dr. The values are calculated in the 3-D
% grid points of X, Y, Z [N,M,n]. The Gaussians can be tilted an
% angle mag_ze away from e_z in the Y-Z plane.
% 
% Calling:
%  [V_em] = dI3D_multiple(I0_r0_dr,X,Y,Z,dt,tau,mag_ze)
% 
% Input:
%  I0_r0_dr - array of prameters:
%  I0_r0_dr(1:11:end-4) - I0, peak values of Gaussians (respectively)
%  I0_r0_dr(2:11:end-4) - x0, center points in x direction
%  I0_r0_dr(3:11:end-4) - y0, center points in y direction
%  I0_r0_dr(4:11:end-4) - z0, center points in z direction
%  I0_r0_dr(5:11:end-4) - sx, width in x direction
%  I0_r0_dr(6:11:end-4) - sy, width in y direction
%  I0_r0_dr(7:11:end-4) - sz, width in z direction below z0
%  I0_r0_dr(8:11:end-4) - sz, width in z direction above z0
%  I0_r0_dr(9:11:end-4) - gamma, exponent of Gaussian exp(-d^gamma) vertical
%  I0_r0_dr(10:11:end-4) - fi, rotation of horisontal elipsoid.
%  I0_r0_dr(11:11:end-4) - gammaxy exponent of Gaussian exp(-d^gammaxy) horisontal
%  I0_r0_dr(end-3) - wind in x-direction (unused)
%  I0_r0_dr(end-2) - wind in y-direction (unused)
%  I0_r0_dr(end-1) - wind in z-direction (unused)
%  I0_r0_dr(end)   - Diffusion parameter (unused)
%  X - x-coordinate of 3-D grid
%  Y - y-coordinate of 3-D grid
%  Z - z-coordinate of 3-D grid
%  dt - unused,
%  tau - unused, 
%  mag_ze - rotation angle from e_z (radians) in the Y-Z plane.
% 
% Note: I0_r0_dr has to have size [1x(4+N*11)], N being the number
% off Gaussians, the function automatically calculates the number
% of Gaussians used through: N = length(I0_r0_dr(1:end-4))/11 which
% has to be an integer.


%   Copyright © 20071129 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin < 7
  mag_ze = 12*pi/180;
end

V_em = zeros(size(X));

I0_r0_dr = reshape(I0_r0_dr(1:end-4), ...
		   [11 length(I0_r0_dr(1:end-4))/11])';

for i1 = 1:min(size(I0_r0_dr)),
  
  I0 = I0_r0_dr(i1,1);
  x_0 = I0_r0_dr(i1,2);
  y_0 = I0_r0_dr(i1,3);
  z_0 = I0_r0_dr(i1,4);
  dsx = I0_r0_dr(i1,5);
  dsy = I0_r0_dr(i1,6);
  dsz1 = I0_r0_dr(i1,7);
  dsz2 = I0_r0_dr(i1,8);
  gamma = abs(I0_r0_dr(i1,9));
  fi1 = I0_r0_dr(i1,10);
  gamma_xy = I0_r0_dr(i1,11);
  alfa = 2;
  %first try with two sided generalised Gaussian!
  Ixyz = exp(-abs( ( abs((X-x_0(end))*cos(fi1)+(Y-y_0)*sin(fi1)).^alfa ...
		     /dsx(end)^alfa ...
		     + abs((Y-( y_0(end) - sin(mag_ze)*(Z-z_0(end)) ))* ...
			   cos(fi1)-(X-x_0(end))*sin(fi1)).^alfa ...
		     /dsy(end)^alfa ).^(2/alfa) ...
		   + (Z-z_0(end)).^2 ...
		   /dsz1(end)^2.*(Z<z_0(end)) ...
		   + (Z-z_0(end)).^2 ...
		   /dsz2(end)^2.*(Z>=z_0(end))).^gamma(end));
  
  %den vore nog bra att koera genom iterator.
  %notfiniteindx = find(~isfinite(Ixyz(:)));
  %Ixyz(notfiniteindx) = 0;
  Ixyz(~isfinite(Ixyz(:))) = 0;
  V_em = V_em + I0(end)*Ixyz;
  
end
