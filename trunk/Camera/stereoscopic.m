function [r,l,mindiff] = stereoscopic(r1,e1,r2,e2)
% STEREOSCOPIC calculate the shortest intersection between 2 lines.
% The lines should be given as a start point Ri and a direction
% vector Ei.
%
% Calling:
%  [r,l,mindiff] = stereo(r1,e1,r2,e2)
% 
% Input:
%  r1 - position of line 1 vertex
%  e1 - unit vector of line 1
%  r2 - position of line 2 vertex
%  e2 - unit vector of line 2
% 
% Output:
%  r       - vector to mid-point of shortest intersection between
%            line 1 and line 2
%  l       - lengths from r1 and r2 respectively to the end-points
%            of the shortest intersection
%  mindiff - length of shortest intersection
% 
% See also TRIANGULATE,


%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% direct algebra inversion!!!
rhs = [dot(r2,e1)-dot(r1,e1) dot(r2,e2)-dot(r1,e2)];
M = [1 -dot(e1,e2);dot(e1,e2) -1];
% This is what we calculate below: l = (inv(M)*rhs')';
l = (M\rhs')';

mindiff = diff2_ps_on_ls(l,r1,e1,r2,e2);

r = .5*(r1+l(1)*e1+r2+l(2)*e2);
