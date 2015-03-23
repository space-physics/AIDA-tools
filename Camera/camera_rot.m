function [rmat] = camera_rot(alfa,beta,gamma,order)
% CAMERA_ROT - determines the coordinate system of the camera 
%  ( e3 as the optical axes )  ALFA, BETA, GAMMA are rotation
%  angles in degrees. Calculates rotation matrix for Tait-Bryant
%  angles.
%
% Calling:
% [rmat] = camera_rot(alfa,beta,gamma)
% 
% Input:
%  alfa  - rotation angle around e_2, degrees
%  beta  - rotation angle around e_1, degrees
%  gamma - rotation angle around e_3, degrees
% 
% See also CAMERA_BASE


%   Copyright � 20010330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


ral = alfa*pi/180;
rbe = beta*pi/180;
rgamma = gamma*pi/180;

rot1(1,1) = cos(rgamma);
rot1(1,2) = -sin(rgamma);
rot1(1,3) = 0;
rot1(2,1) = sin(rgamma);
rot1(2,2) = cos(rgamma);
rot1(2,3) = 0;
rot1(3,1) = 0;
rot1(3,2) = 0;
rot1(3,3) = 1;

rot2(1,1) = cos(ral);
rot2(1,2) = 0;
rot2(1,3) = sin(ral);
rot2(2,1) = 0;
rot2(2,2) = 1;
rot2(2,3) = 0;
rot2(3,1) = -sin(ral);
rot2(3,2) = 0;
rot2(3,3) = cos(ral);

rot3(1,1) = 1;
rot3(1,2) = 0;
rot3(1,3) = 0;
rot3(2,1) = 0;
rot3(2,2) = cos(rbe);
rot3(2,3) = sin(rbe);
rot3(3,1) = 0;
rot3(3,2) = -sin(rbe);
rot3(3,3) = cos(rbe);

if nargin > 3 && order == 1
  rmat = rot1*rot2*rot3;
else
  rmat = rot2*rot3*rot1;
end
