function [a2,b2,g2] = oldrots2newerrots(a1,b1,g1)
% OLDROTS2NEWERROTS - Transformation between 2 set of rotation angles 
%   Method: Just some simle trigonometry and a little trivial
%   algebra, nothing fancy really. Typical scribble on a napkin
%   type of maths.
% Calling:
% [a2,b2,g2] = oldrots2newerrots(a1,b1,g1)

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

a2(1) = [  atan2(sin(a1)*cos(b1),(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];
a2(2) = [ atan2(sin(a1)*cos(b1),-(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];

b2(1) = [   atan2(sin(b1)/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2),cos(a1)*cos(b1)/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];
b2(2) = [ atan2(-sin(b1)/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2),-cos(a1)*cos(b1)/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];

g2(1) = [   atan2((cos(a1)*sin(g1)+sin(a1)*sin(b1)*cos(g1))/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2),(cos(a1)*cos(g1)-sin(a1)*sin(b1)*sin(g1))/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];
g2(2) = [ atan2(-(cos(a1)*sin(g1)+sin(a1)*sin(b1)*cos(g1))/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2),-(cos(a1)*cos(g1)-sin(a1)*sin(b1)*sin(g1))/(-sin(a1)^2+sin(a1)^2*sin(b1)^2+1)^(1/2))];

% I told you so it was nothing here to see. Gotcha!

