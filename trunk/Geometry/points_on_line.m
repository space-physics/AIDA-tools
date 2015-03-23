function  [r_out] = points_on_line(r_0,e_l,l)
% POINTS_ON_LINE calculates the vector to a set of points R_OUT
% that are L away from R_0 in the direction E_L.
% 
% Example:
%   r_0 = [0 0 1];
%   e_l = [.1 .8 .3]'/sum([.1 .8 .3].^2).^.5;
%   l = [-3:3];
%   [r_out] = points_on_line(r_0,e_l,l);


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r_out = e_l*l;
r_out(1,:) = r_0(1)+r_out(1,:);
r_out(2,:) = r_0(2)+r_out(2,:);
r_out(3,:) = r_0(3)+r_out(3,:);
