function [diff] = stardiff4(fv,x,y,starmat,x0,y0,d_x0y0)
% STARDIFF4 - total error of starfield fit.
% 
% STARDIFF4 calculates the sum of the square of deviation of 
% a 2D gaussian clock and the intensity  of the image ( 10x10 )
% above the mean of the frame  of the image.
% 
% The function is used for automatic fitting of a 2D Gaussian to
% fit a star intensity distribution, and thus finding the star.
%
% Calling:
%  [diff] = stardiff4(fv,x,y,starmat,x0,y0,d_x0y0)

%   Copyright © 20070702 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

delta_x0y0 = 100;
if nargin>8
  
  delta_x0y0 = d_x0y0;
  
end

stari = fv(3)*exp(- ( ( x - fv(1) ).^2 / fv(4)^2 + ...
                      2*fv(5)*(x-fv(1)).*(y-fv(2)) + ...
                      ( y - fv(2) ).^2 / fv(6)^2 ) );

diffm = starmat - stari;
diff = sum(diffm(:).^2) + delta_x0y0*((fv(1)-x0)^2+(fv(2)-y0)^2);
[maxI,maxIindx] = max(starmat(:));
[maxM,maxMindx] = max(stari(:));
diff = diff + ...
       100 * ( x(maxMindx) - x(maxIindx) )^2 + ...
       100 * ( y(maxMindx) - y(maxIindx) )^2 + abs(fv(3))*(fv(3)<0)*10;
