function [img_out,ff] = ffs_correction(img,optpar,optmod)
% FFS_CORRECTION - flat-field variation for optical transfer
% function OPTMOD with optical parameters OPTPAR. Calculated for
% images with size of IMG.
% 
% Calling:
% [img_out,ff] = ffs_correction(img,optpar,optmod)
% 
% Input:
%  img    - image to flat-field correct
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor.
%  optmod - identifier for optical transfer function [-2,-1,1,2,3,4,5]
%
% Output:
%  IMG_OUT - flat-field corrected image,
%  FF      - flat-field correction matrix
% 
% See also FFS_CORRECTION CAMERA_MODEL, DETERMINE_FOV


%   Copyright � 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


bxy = size(img);
bx = bxy(2);
by = bxy(1);

% £££ dmax = 0;

v = 1:by;
u = 1:bx;
[u,v] = meshgrid(u,v);

[phi,theta] = camera_invmodel(u(:),v(:),optpar,optmod,size(img));

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
  % £££ [dssdx,dssdy] = gradient(optpar.sinzesinaz);
  % £££ [dscdx,dscdy] = gradient(optpar.sinzecosaz);
  [dssdx,dssdy] = gradient(sinzesinaz);
  [dscdx,dscdy] = gradient(sinzecosaz);
  dohmega_Aeff = ( (dssdx.^2+dssdy.^2).*(dscdx.^2+dscdy.^2) ).^.5;
  % Since we _realy_ want the solid angle _multiplied_ with the
  % cosine of the angle to the z-axis - we can take the area of the
  % projection to the x-y plane and run!
  
  dmax = max(dohmega_Aeff(:));
  img_out = img;
  img_out = img_out./dohmega_Aeff;
  
else
  dohmega_Aeff = dohmega(theta,optpar,optmod,optpar(8)).*cos(theta);
  dmax = max(dohmega_Aeff);
  img_out = img;
  img_out(:) = img_out(:)./dohmega_Aeff;
end

if ( nargout > 1 )
  ff = img;
  ff(:) = dohmega_Aeff(:);
end

img_out = img_out*dmax;
