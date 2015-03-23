function [starintens] = starint3(fv,xmin,xmax,ymin,ymax)
% STARINT3 evaluation of a 2D gaussian.
% 
% STARINT3 calculates a 2D gaussian on a matrix located
% between (xmin,xmax) and (ymin,ymax) the maxintensity
% and the spread of the gaussian is given in the array
% FV.
% 
% Calling:
% [starintens] = starint3(fv,xmin,xmax,ymin,ymax)


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

x = xmin:xmax;
y = ymin:ymax;
[xx,yy] = meshgrid(x,y);
%xx = xx;
%yy = yy;

starintens = fv(3)*exp(- ( ( xx - fv(1) ).^2 / fv(4)^2 + ...
                      2*fv(5)*(xx-fv(1)).*(yy-fv(2)) + ...
                      ( yy - fv(2) ).^2 / fv(6)^2 ) );
