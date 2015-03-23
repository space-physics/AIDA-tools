function  [r_out] = point_on_line2(r_0,e_l,l)
% POINT_ON_LINE calculates the vector to a set of points R_OUT
% that are L away from R_0 in the direction E_L.
% 
% Calling:
% [r_out] = point_on_line2(r_0,e_l,l);


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r_out = e_l*l;
r_out(1,:) = r_0(1)+r_out(1,:);
r_out(2,:) = r_0(2)+r_out(2,:);
r_out(3,:) = r_0(3)+r_out(3,:);
