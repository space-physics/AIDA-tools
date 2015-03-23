function [ff] = ffs_correction2(imgsize,optpar,optmod)
% FFS_CORRECTION2 - flat-field variation for optical transfer
% function OPTMOD with optical parameters OPTPAR. Calculated for
% images with size IMGSIZE.
% 
% Calling:
% [ff] = ffs_correction2(imgsize,optpar,optmod)
% 
% Input:
%  imgsize - size of image (pixels)
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor.
%  optmod - identifier for optical transfer function [-2,-1,1,2,3,4,5]
% 
% Output:
%  FF - flat-field correction matrix, scaled to max==1
% 
% See also FFS_CORRECTION_RAW CAMERA_MODEL, DETERMINE_FOV


%   Copyright � 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


bxy = imgsize;
bx = bxy(2);
by = bxy(1);

% £££ dmax = 0;

v = 1:by;
u = 1:bx;
[u,v] = meshgrid(u,v);

if optmod < 0
  
  u = u/bx;
  v =  v/by;
  u_i = linspace(0,1,50);
  v_i = linspace(0,1,50);
  sinzecosaz = interp2(u_i,v_i,optpar.sinzecosaz,u,v);
  sinzesinaz = interp2(u_i,v_i,optpar.sinzesinaz,u,v);
  % The solid angle spanned by a pixel field-of-view is the area of
  % the projection of that surface onto the x-y plane divided by
  % the cosine of the angle to the z-axis. The area of the x-y
  % projection we can get by using the gradient of the horisontal
  % projections of the l-o-s vectors. (And dear old Pythagoras)
  [dssdx,dssdy] = gradient(sinzesinaz);
  [dscdx,dscdy] = gradient(sinzecosaz);
  dohmega_Aeff = ((dssdx.^2+dssdy.^2).*(dscdx.^2+dscdy.^2)).^.5;
  % Since we _realy_ want the solid angle _multiplied_ with the
  % cosine of the angle to the z-axis - we can take the area of the
  % projection to the x-y plane and run!
  ff = ones(imgsize);
  ff(:) = dohmega_Aeff/max(dohmega_Aeff(:));
  
else
  
  [phi,theta] = camera_invmodel(u(:),v(:),optpar,optmod,imgsize);
  dohmega_Aeff = dohmega(theta,optpar,optmod,optpar(8)).*cos(theta);
  ff = ones(imgsize);
  [min_theta,i_min_theta] = min(abs(theta(:)));
  ff(:) = dohmega_Aeff/dohmega_Aeff(i_min_theta);
  
end
