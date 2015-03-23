function [V_em] = I3d_p_dI3D(I0_r0_dr,X,Y,Z,I0_R0_DR,t_in,T,tau,I3d,dI3d)
% I3d_p_dI3D - Integration of continuity equation with sources
% loss-rates drifts and diffusion, a pseudo-analytical scheme is
% used. 
% 
% Calling: 
%  [V_em] = I3d_p_dI3D(I0_r0_dr,X,Y,Z,I0_R0_DR,t_in,T,tau,I3d,dI3d)
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
%  I0_r0_dr(end-3) - wind in x-direction
%  I0_r0_dr(end-2) - wind in y-direction
%  I0_r0_dr(end-1) - wind in z-direction
%  I0_r0_dr(end)   - Diffusion parameter
%  X - x-coordinate of 3-D grid [NxMxn]
%  Y - y-coordinate of 3-D grid [NxMxn]
%  Z - z-coordinate of 3-D grid [NxMxn]
%  t_in - time step to integrate over, dt = t_in(end)-t_in(end-1)
%  tau - lifetime of the species created, same sized as X, Y, Z, V_em
%  I3d  - input concentration of speices at t_in(end-1),[NxMxn]
%  dI3d - production during t_in(end-1):t_in(end), [NxMxn]



%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

vx =   I0_r0_dr(end-3);
vy =   I0_r0_dr(end-2);
vz =   I0_r0_dr(end-1);
Diff = I0_r0_dr(end).^2;

t = t_in; % fixa!

dx = vx*(t(end)-t(end-1));
dy = vy*(t(end)-t(end-1));
dz = vz*(t(end)-t(end-1));


% accounting for drift:
V_em = interp3(X,Y,Z,permute(I3d,[2 1 3]),...
               X-dx,Y-dy,Z-dz);
V_em = permute(V_em,[2 1 3]);
%i1 = find(~isfinite(V_em(:)));
%V_em(i1) = 0;
V_em(~isfinite(V_em(:))) = 0;

V_tot = sum(V_em(:)); % total emission should be conserved durin
                      % diffusion 

% acconting for diffusion
[x,y,z] = meshgrid([-3:3],[-3:3],[-3:3]);
Ixyz_diff = ( 1/(pi*Diff(end)*(t(end)-t(end-1)))^1.5 ...
	      *exp(-( (x).^2 + (y).^2 + (z).^2 ) ...
		   /(Diff(end)*(t(end)-t(end-1)))) );

V_em = convn(V_em,Ixyz_diff/sum(Ixyz_diff(:)),'same');
%i1 = find(~isfinite(V_em(:)));
%V_em(i1) = 0;
V_em(~isfinite(V_em(:))) = 0;
V_t_d = sum(V_em(:));

if ( V_t_d > 0 )
  
  V_em = V_em*V_tot/V_t_d; % Conserving total emission
  
end

% accounting for decay with appropriate lifetime.
It = exp(-(t(end)-t(end-1))./tau);
V_em = It.*V_em;

V_em = V_em+dI3d;
if any(V_em(:)<0)
  keyboard
end
