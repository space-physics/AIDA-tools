function [Vem,r,XfI,YfI,ZfI] = tomo_set_blockofblobs(r0,dr1,dr2,dr3,sizes_yxz)
% TOMO_SET_BLOCKOFBLOBS - setup function  for b-o-b geometry parameters
%  Unfinished
%
% Calling:
%  [Vem,r,XfI,YfI,ZfI] = tomo_set_blockofblobs(r0,dr1,dr2,dr3,sizes_yxz)


%   Copyright © 2008 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

Vem = zeros(sizes_yxz);
% set the lower south-west corner:
%ds = 2.5;
%r0 = [-128 -64 80];
%r0 = r_B + [-64*ds -64*ds 80]+[10 0 0];
% Define the latice unit vectors
%dr1 = [ds 0 0];
%dr2 = [0 ds 0];
% With e3 || vertical:
%dr3 = [0 0 ds];
% or || magnetic zenith:
%dr3 = [0 -ds*tan(pi*12/180) ds];
% Calculate duplicate arrays for the position of the base functions:
[r,X,Y,Z] = sc_positioning(r0,dr1,dr2,dr3,Vem);
XfI = r0(1)+dr1(1)*(X-1)+dr2(1)*(Y-1)+dr3(1)*(Z-1);
YfI = r0(2)+dr1(2)*(X-1)+dr2(2)*(Y-1)+dr3(2)*(Z-1);
ZfI = r0(3)+dr1(3)*(X-1)+dr2(3)*(Y-1)+dr3(3)*(Z-1);
