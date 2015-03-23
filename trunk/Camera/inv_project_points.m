function [xx,yy,zz] = inv_project_points(px,py,img_in,r,optmod,optpar,e_n,l_0,cmtr)
% INV_PROJECT_POINTS - maps points (PX,PY) in image IMG_IN to a plane
%   IMG_IN is taken from point R with a camera model OPTMOD and
%   rotation and optical transfer function caracterised by OPTPAR
%   on a plane with a normal E_N at distance L_O. CMTR is an
%   optional correction rotation matrix.
%
% Calling:
% [xx,yy,zz] = inv_project_points(px,py,img_in,r,optmod,optpar,e_n,l_0,cmtr)
% 
% Input:
%  px     - [1xn] (or [nx1]) horisontal pixel coordinates for points to
%           project.
%  py     - [1xn] (or [nx1]) vertical pixel coordinates for points to
%           project.
%  img_in - image used only to get pixel range
%  r      - [1x3] (or [3x1]) array for camera position, 
%  optmod - identifier for optical transfer function [-2,-1,1,2,3,4,5]
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor.
%  e_n    - normal vector of plane to project to
%  l_0    - distance from r to plane.
%  cmtr   - additional rotation matrix
% 
%       See also: camera_model, camera_inv_model


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% Calculate the camera rotation
if optmod < 0
  rotmtr = camera_rot(optpar.rot(1),optpar.rot(2),optpar.rot(3));
elseif length(optpar) == 10 && optpar(10) == 213
  rotmtr = camera_rot(0,optpar(4),0)*camera_rot(optpar(3),0,0);
elseif optmod ~= 11
  rotmtr = camera_rot(optpar(3),optpar(4),optpar(5));
else
  rotmtr = eye(3);
end

% Correct for the rotation relative the "central-station" of the
% local coordinate system:
if nargin>8
  rotmtr = cmtr*rotmtr;
end

% Calculate the pixel line-of-sigh directions in the camera
% coordinate system:
[fi,taeta] = camera_invmodel(px,py,optpar,optmod,size(img_in));
epix = [sin(taeta).*sin(fi); sin(taeta).*cos(fi); cos(taeta)];
% Rotate/Transform them with the rotation matrix:
epix = rotmtr*epix;
epix = epix';

% Calculate distance from camera location in r to the plane:
l = l_0 - dot(r,e_n);
rde_n = e_n(1)*epix(:,1) + e_n(2)*epix(:,2) + e_n(3)*epix(:,3);
l = l./rde_n;

% And calculate the intersection between lines-of-sight and plane:
xx = r(1) + l.*epix(:,1);
yy = r(2) + l.*epix(:,2);
zz = r(3) + l.*epix(:,3);
