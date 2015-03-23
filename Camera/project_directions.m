function [ua,wa] = project_directions(az,ze,optpar,optmod,imgsiz)
% PROJECT_DIRECTIONS - calculates the image positions [UA,WA] from (AZ,ZE) 
%   Where AZ is the azimuht angle (clockwise from north) and ZE is
%   the zenigh angle. OPTPAR is a vector caracterising the optical
%   transfer function and the rotation of the camera. OPTMOD is the
%   optical transfer funciton
% 
% Calling:
% [ua,wa] = project_directions(az,ze,optpar,optmod,imgsiz)
% 
% Input:
%  az     - azimuth angle, clockwise from north, in radians.
%  ze     - zenith angle, radians.
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor.
%  optmod - identifier for optical transfer function [-2,-1,1,2,3,4,5]
%  imsiz  - size of image [1x2]
% 
% See also CAMERA_MODEL, PROJECT_POINT, INV_PROJECT_DIRECTION

%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if optmod < 0
  
  [e1,e2,e3] = camera_base(optpar.rot(1),optpar.rot(2),optpar.rot(3));
  
else
  
  alpha0 = optpar(3);
  beta0 = optpar(4);
  gamma0 = optpar(5);
  if length(optpar) > 9
    [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,optpar(10));
  else
    [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
  end
end
if nargin >= 5
  
  [ua,wa] = camera_model(az,ze,e1,e2,e3,optpar,optmod,imgsiz);
  
else
  
  [ua,wa] = camera_model(az,ze,e1,e2,e3,optpar,optmod);
  
end
