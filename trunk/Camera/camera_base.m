function [e1,e2,e3] = camera_base(alfa,beta,fi,order)
%  CAMERA_BASE - determine the coordinate system of the camera 
%  ( e3 as the optical axes ). ALFA, BETA, FI are rotation angles
%  in degrees, (TAIT-BRYANT?).
%
% Calling:
% [e1,e2,e3] = camera_base(alfa,beta,fi)
% 
% Input:
%  alfa  - rotation angle around e_2, degrees
%  beta  - rotation angle around e_1, degrees
%  gamma - rotation angle around e_3, degrees
% 
% See also CAMERA_ROT


%   Copyright © 20010330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin > 3
  [rmat] = camera_rot(alfa,beta,fi,order);
else
  [rmat] = camera_rot(alfa,beta,fi);
end

e1 = [1;0;0];
e2 = [0;1;0];
e3 = [0;0;1];

e1 = rmat*e1;
e2 = rmat*e2;
e3 = rmat*e3;

