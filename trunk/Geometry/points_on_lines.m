function  [r_out] = points_on_lines(r_0,e_l,l)
% POINTS_ON_LINES calculates the vectors to a set of points R_OUT
% that are L away from R_0 in the directions E_L. One point pre
% line version, that is E_L should be an array with unit vectors
% sized [Npoints x 3] and L should be the respective lengths away
% in those directions with size [ Npoints x 1]
% 
% Example:
%   r_0 = [0 0 1];
%   e_l = [.1 .8 .3]'/sum([.1 .8 .3].^2).^.5;
%   l = [3];
%   [r_out] = points_on_lines(r_0,e_l,l);
%
%

%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r_out(3,:) = r_0(3) + l.*e_l(:,3);
r_out(2,:) = r_0(2) + l.*e_l(:,2);
r_out(1,:) = r_0(1) + l.*e_l(:,1);
