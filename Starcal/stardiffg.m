function [diff] = stardiffg(fv,xmin,xmax,ymin,ymax,starmat)
% STARDIFFG - total error of starfield fit.
% 
% STARDIFFG calculates the sum of the square of deviation of 
% a 2D gaussian clock and the intensity  of the image ( 10x10 )
% above the mean of the frame  of the image.
% 
% The function is used for automatic fitting of a 2D Gaussian to
% fit a star intensity distribution, and thus finding the star.
%
% Calling:
% [diff] = stardiff(fv,xmin,xmax,ymin,ymax,starmat)
% 



%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ( length(fv) > 6 )
  g = fv(7);
else
  g = 2;
end
x = xmin:xmax;
y = ymin:ymax;
[xx,yy] = meshgrid(x,y);
% xx = xx;%';
% yy = yy;%';

background = ( mean(starmat(1,:)) + mean(starmat(end,:)) + mean(starmat(:,end)) + mean(starmat(:,1)) )/4;

stari = fv(3)*exp(-((fv(4)*(xx-fv(1)).^2 + ... 
                     2*fv(5)*(xx-fv(1)).*(yy-fv(2)) + ...
                     fv(6)*(yy-fv(2)).^2)).^(g/2));

diffm = starmat-background-stari;
diff = sum(diffm(:).^2);
