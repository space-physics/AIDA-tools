function [diff] = stardiff3(fv,xmin,xmax,ymin,ymax,starmat,x0,y0,d_x0y0)
% STARDIFF3 - total error of starfield fit.
% 
% STARDIFF3 calculates the sum of the square of deviation of 
% a 2D gaussian clock and the intensity  of the image ( 10x10 )
% above the mean of the frame  of the image.
% 
% The function is used for automatic fitting of a 2D Gaussian to
% fit a star intensity distribution, and thus finding the star.
% 
% Calling:
%  [diff] = stardiff3(fv,xmin,xmax,ymin,ymax,starmat,x0,y0,d_x0y0)


%   Copyright © 19981022 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

delta_x0y0 = 100;
if nargin>8
  
  delta_x0y0 = d_x0y0;
  
end
x = xmin:xmax;
y = ymin:ymax;
[xx,yy] = meshgrid(x,y);

background = mean([starmat(1,:) starmat(end,:) starmat(:,end).' starmat(:,1).']);
stari = fv(3)*exp(- ( ( xx - fv(1) ).^2 / fv(4)^2 + ...
                      2*fv(5)*(xx-fv(1)).*(yy-fv(2)) + ...
                      ( yy - fv(2) ).^2 / fv(6)^2 ) );

diffm = starmat-background-stari;
diff = sum(diffm(:).^2) + delta_x0y0*((fv(1)-x0)^2+(fv(2)-y0)^2);
[maxI,maxIindx] = max(starmat(:)-background(:));
[maxM,maxMindx] = max(stari(:));
diff = diff + abs(fv(3)*(fv(3)<0))*10 + ...
       100 * ( xx(maxMindx) - xx(maxIindx) )^2 + ...
       100 * ( yy(maxMindx) - yy(maxIindx) )^2;
