function [u,v,l] = project_point(rs,optpar,r,cmtr,imsiz)
% PROJECT_POINT - project a point in space R down onto an image
% point [U,V]. The imager is located in RS and the 
%   optical transfer is caracterized by OPTPAR. CMTR is a
%   correction matrix for the rotations (optional)
%
%Calling:
% [u,v] = project_point(r_stn,optpar,r,cmtr,imsiz)
% 
% Input:
%  rs     - [1x3] (or [3x1]) array for camera position. 
%  r      - [nx3] (or [3xn]) array of point coordinates.
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor, optical
%           model.
%  cmtr   - additional rotation matrix
%  imsiz  - size of image.
%
% See also CAMERA_BASE, CAMERA_MODEL, INV_PROJECT_POINT

%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin < 5 || isempty(imsiz)
  imsiz = [bx by];
end

% Defining the rotated coordinate system of the cameras.
if isstruct(optpar)
  optmod = optpar.mod;
  if isfield(optpar,'rot')
    [e1_1,e1_2,e1_3] = camera_base(optpar.rot(1),optpar.rot(2),optpar.rot(3));
  else
    [e1_1,e1_2,e1_3] = camera_base(0,0,0);
  end
else
  if length(optpar) > 9
    [e1_1,e1_2,e1_3] = camera_base(optpar(3),optpar(4),optpar(5),optpar(10));
  else
    [e1_1,e1_2,e1_3] = camera_base(optpar(3),optpar(4),optpar(5));
  end
  optmod = optpar(9);
end
if nargin > 3 && ~isempty(cmtr)
  e1_1 = cmtr*e1_1;
  e1_2 = cmtr*e1_2;
  e1_3 = cmtr*e1_3;
end  
% To define a baseline for a vertical plane trough 2 stations.

if size(r,2)>1
  
  r1tmp(1,:) = r(1,:)-rs(1);
  r1tmp(2,:) = r(2,:)-rs(2);
  r1tmp(3,:) = r(3,:)-rs(3);
  
  az1 = atan2(r1tmp(1,:),r1tmp(2,:));
  ze1 = atan((r1tmp(1,:).^2+r1tmp(2,:).^2).^.5./r1tmp(3,:));
  %disp(ze1(1)*180/pi)
else
  
  r1tmp(1) = r(1)-rs(1);
  r1tmp(2) = r(2)-rs(2);
  r1tmp(3) = r(3)-rs(3);
  
  az1 = atan2(r1tmp(1),r1tmp(2));
  ze1 = atan((r1tmp(1).^2+r1tmp(2).^2).^.5./r1tmp(3));
  
end

[u,v] = camera_model(az1,ze1,e1_1,e1_2,e1_3,optpar,optmod,imsiz);
if ( nargout == 3 )
  
  l = ( r1tmp(1,:).^2 + r1tmp(2,:).^2 + r1tmp(3,:).^2).^.5;
  
end
