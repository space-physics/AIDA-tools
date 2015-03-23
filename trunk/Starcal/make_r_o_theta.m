function [r,theta] = make_r_o_theta(az,ze,u,v,optpar,imgsize)
% Function that determines the image coordinates of light from a
% point source in the direction described by the azimuth and zenith
% angles AZ, ZE. E1, E2 and E3 are the rotated camera coordinate
% system. OPTPAR is the optical parameters
% OPTPAR(1) is the horizontal focal widht (percent of the image size )
% OPTPAR(2) is the vertical focal width (percent of the image size )
% OPTPAR(6) is the horizontal displacement of the optical axis
% OPTPAR(7) is the vertical displacement of the optical axis
% OPTPAR(8) is a correction factor for deviations from a pin-hole
% camera-model. All parameters are relative to the image size.
% MODE is the camera-model-number.
%
% Calling:
% [r,theta] = make_r_o_theta(az,ze,u,v,optpar,mode,imgsize)

% OBSOLETE?

%   Copyright © 20010330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


%global bx by
disp('Function: make_r_o_theta used from:')
dbstack

f1 = optpar(1);
f2 = optpar(2);
az0 = optpar(3);
el0 = optpar(4);
roll = optpar(5);
dx = optpar(6);
dy = optpar(7);
alfa = optpar(8);

if isstruct(optpar)
  [e1,e2,e3] = camera_base(0,0,0);
else
  [e1,e2,e3] = camera_base(az0,el0,roll);
end
raz = az;
rze = ze;

es(1,:) = sin(rze).*sin(raz);
es(2,:) = sin(rze).*cos(raz);
es(3,:) = cos(rze);

ese1(1,:) = es(1,:)*e1(1);
ese1(2,:) = es(2,:)*e1(2);
ese1(3,:) = es(3,:)*e1(3);
sese1 = sum(ese1);

ese2(1,:) = es(1,:)*e2(1);
ese2(2,:) = es(2,:)*e2(2);
ese2(3,:) = es(3,:)*e2(3);
sese2 = sum(ese2);

ese3(1,:) = es(1,:)*e3(1);
ese3(2,:) = es(2,:)*e3(2);
ese3(3,:) = es(3,:)*e3(3);
sese3 = sum(ese3);

theta = atan(((sese1).^2+(sese2).^2).^.5./(sese3));
% For optmod == -1 there need to be some clever modifications here.
% optpar(6,7) should be where ze==pi/2,
% But as -1 assumes no rotations whatsoever this function is fairly
% esoteric
r = ((u-imgsize(2)*(1/2+optpar(6))).^2+(v-imgsize(1)*(1/2+optpar(7))).^2).^.5;
