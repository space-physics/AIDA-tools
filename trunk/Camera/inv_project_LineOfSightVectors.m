function epix = inv_project_LineOfSightVectors(px,py,inimg,r,optmod,optpar,e_n,l_0,cmtr)
% INV_PROJECT_LineOfSightVectors - pixels coordinates to line-of-sight vectors
% 
%            in an image inimg taken from point R with a camera
%            model OPTMOD and rotation and optical transfer
%            function caracterised by OPTPAR on a plane with a
%            normal E_N at distance L_O. CMTR is an optional
%            correction rotation matrix.
% Calling:
% epix = inv_project_LineOfSightVectors(px,py,inimg,r,optmod,optpar,e_n,l_0,cmtr)
%
% Input:
%  PX,PY - arrays of horizontal and vertical pixel coordinates.
%  INIMG - image needed to provide its size.
%  R     - camera location 1x3 array. unused,
%  OPTMOD - number for optical characteristics/optical model of the
%           camera.
%  OPTPAR - optical parameters. 
%  E_N    - Unused, unit vector perpendicular to a plane.
%  L_0    - Unused, length to a plane.
%  CMTR   - Optional correction matrix, for camera rotation.
%
%       See also camera_model, camera_inv_model


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


bxy = size(inimg);

% Calculate the camera rotation
if optmod < 0
  rotmtr = camera_rot(optpar.rot(1),optpar.rot(2),optpar.rot(3));
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
[phi,theta] = camera_invmodel(px,py,optpar,optmod,bxy);
epix = [sin(theta).*sin(phi); sin(theta).*cos(phi); cos(theta)];
% Rotate/Transform them with the rotation matrix:
epix = rotmtr*epix;
epix = epix';
