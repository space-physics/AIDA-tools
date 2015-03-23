function  [r_out] = point_on_line(r_0,e_l,l)
% POINT_ON_LINE calculates the vector to a point R_OUT
% that are L away from R_0 in the direction E_L.
% 
% Calling:
%   [r_out] = poin_on_line(r_0,e_l,l);

%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


r_out = r_0+l*e_l;
