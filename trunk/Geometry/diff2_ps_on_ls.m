function [diff2] = diff2_ps_on_ls(l,r1,e1,r2,e2)
% DIFF2_PS_ON_LS calculates squared distance between points on 2 different lines.
% 
% Calling:
% [diff2] = diff2_ps_on_ls(l,r1,e1,r2,e2)
% 
% Input:
%  R1 and R2 are the start points of the lines. [1x3], [1x3]
%  E1 and E2 are the direction of the lines.  [1x3], [1x3]
%  L(1), L(2) are the length along the lines from R1 and R2
%  respectivelly
% 


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r_1 = r1 + l(1)*e1;
r_2 = r2 + l(2)*e2;

diff2 = ((r_1 - r_2)*(r_1 - r_2)').^(1/2);
