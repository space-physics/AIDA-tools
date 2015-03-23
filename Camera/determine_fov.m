function fov = determine_fov(imgsiz,optpar,optmod)
% DETERMINE_FOV - determine field-of-view of optics
% with optical transfer function OPTMOD with optical parameters
% OPTPAR
%
% Calling:
% fov = determine_fov(imgsiz,optpar,optmod)
% 
% Input:
%   IMGSIZ - image size
%   OPTPAR - optical parameters
%   OPTMOD - optical model,
% 
% See also: CAMERA_MODEL, CAMERA_INV_MODEL


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



global bx
global by

bx = imgsiz(1);
by = imgsiz(2);

[fi,taeta] = camera_invmodel([1 1 imgsiz(1)],...
                             [1 imgsiz(2) imgsiz(2)],...
                             optpar,optmod,imgsiz);

e_c1 = [sin(taeta(1))*sin(fi(1)) sin(taeta(1))*cos(fi(1)) cos(taeta(1))];
e_c3 = [sin(taeta(2))*sin(fi(2)) sin(taeta(2))*cos(fi(2)) cos(taeta(2))];
e_c2 = [sin(taeta(3))*sin(fi(3)) sin(taeta(3))*cos(fi(3)) cos(taeta(3))];

fov(3) = acos(dot(e_c1,e_c3));
fov(1) = acos(dot(e_c1,e_c2));
fov(2) = acos(dot(e_c2,e_c3));

[fi,taeta] = camera_invmodel([1 imgsiz(1) imgsiz(1)/2 imgsiz(1)/2],...
                             [imgsiz(2)/2 imgsiz(2)/2 1 imgsiz(2)],...
                             optpar,optmod,imgsiz);

e_c1 = [sin(taeta(1))*sin(fi(1)) sin(taeta(1))*cos(fi(1)) cos(taeta(1))];
e_c2 = [sin(taeta(2))*sin(fi(2)) sin(taeta(2))*cos(fi(2)) cos(taeta(2))];
e_c3 = [sin(taeta(3))*sin(fi(3)) sin(taeta(3))*cos(fi(3)) cos(taeta(3))];
e_c4 = [sin(taeta(4))*sin(fi(4)) sin(taeta(4))*cos(fi(4)) cos(taeta(4))];

fov(4) = acos(dot(e_c1,e_c2));
fov(5) = acos(dot(e_c3,e_c4));
