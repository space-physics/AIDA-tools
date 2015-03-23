function [diff] = stardiff2(fv,xStar,yStar,starmat,x0,y0,d_x0y0)
% STARDIFF2 - total error of starfield fit.
% 
% STARDIFF2 calculates the sum of the square of deviation of 
% a 2D gaussian clock and the intensity  of the image ( 10x10 )
% above the mean of the frame  of the image.
% 
% The function is used for automatic fitting of a 2D Gaussian to
% fit a star intensity distribution, and thus finding the star.
%
% Calling:
%  [diff] = stardiff2(fv,xmin,xmax,ymin,ymax,starmat,x0,y0,d_x0y0)

%   Copyright © 19981022 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

delta_x0y0 = 10;
if nargin > 6
  
  delta_x0y0 = d_x0y0;
  
end
% x = xmin:xmax;
% y = ymin:ymax;
% [xStar,yStar] = meshgrid(x,y);
% xStar = xStar;
% yStar = yStar;

background = ( mean(starmat(1,:))   + mean(starmat(end,:)) + ...
	       mean(starmat(:,end)) + mean(starmat(:,1)) )/4;
stari = fv(3)*exp(- ((fv(4)*(xStar-fv(1)).^2 + ...
                      2*fv(5)*(xStar-fv(1)).*(yStar-fv(2)) + ...
                      fv(6)*(yStar-fv(2)).^2)));

diffm = starmat-background-stari+abs(fv(3)*(fv(3)<0));
diff = sum(diffm(:).^2) + delta_x0y0*((fv(1)-x0)^2+(fv(2)-y0)^2);
