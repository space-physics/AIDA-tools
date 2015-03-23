function [Im_proj] = inv_project_img_surf(img_in,r,optmod,optpar,Xs,Ys,Zs,cmtr)
% INV_PROJECT_IMG_SURF - map IMG_IN - onto an arbitrary surface
%  The image IMG_IN taken from point R with a camera model OPTMOD
%  and rotation and optical transfer function caracterised by
%  OPTPAR onto a surface [XS,YS,ZS]. CMTR is an optional correction
%  rotarion matrix.
%
% Calling:
% [Im_proj] = inv_project_img_surf(img_in,r,optmod,optpar,Xs,Ys,Zs,cmtr)
% 
% Input:
%  img_in - image used only to get pixel range
%  r      - [1x3] (or [3x1]) array for camera position, 
%  optmod - identifier for optical transfer function [-2,-1,1,2,3,4,5]
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor.
%  Xs     - [NxM], east coordinate of surface to project image to
%  Ys     - [NxM], north coordinate of surface to project image to
%  Zs     - [NxM], vertical coordinate of surface to project image to
%  cmtr   - additional rotation matrix
%
%       See also INV_PROJECT_IMG, CAMERA_MODEL, CAMERA_INV_MODEL


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% £££  bxy = size(img_in);
% £££  bx = bxy(2);
% £££  by = bxy(1);

% £££ if optmod < 0
% £££   rotmtr = camera_rot(optpar.rot(1),optpar.rot(2),optpar.rot(3));
% £££ else
% £££   rotmtr = camera_rot(optpar(3),optpar(4),optpar(5));
% £££ end

if nargin<8
  cmtr = eye(3);
end

% Calculate image coordinates for points on the surface [X,Y,Z]
[u,v] = project_point(r,optpar,[Xs(:),Ys(:),Zs(:)]',cmtr,size(img_in));

% Get the image intensities for those points by interpolation
Im_proj = Xs;
Im_proj(:) = interp2(img_in,u,v);
