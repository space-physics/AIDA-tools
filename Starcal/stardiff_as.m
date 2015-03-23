function [diff] = stardiff_as(fv,x,y,starmat,x0,y0,xy_err,i_err)
% STARDIFF_AS - total error of starfield fit.
% 
% STARDIFF_AS calculates the sum of the square of deviation of 
% a 2D gaussian clock and the intensity  of the image ( 10x10 )
% above the mean of the frame  of the image.
% 
% The function is used for automatic fitting of a 2D Gaussian to
% fit a star intensity distribution, and thus finding the star.

%       Copyright Bjoern Gustavsson 1998 10 22

% This version by A. Senior, 2007-06-25 with "optimisations" for
% the spectral calibration code

stari = fv(3)*exp(- ( ( x - fv(1) ).^2 / fv(4)^2 + ...
                      2*fv(5)*(x-fv(1)).*(y-fv(2)) + ...
                      ( y - fv(2) ).^2 / fv(6)^2 ) );

diffm=(starmat-stari)/i_err;

% total error is sum of squares of intensity differences plus
% squares of differences of model star centre from predicted position

diff=sum(diffm(:).^2) + ((fv(1)-x0)/xy_err)^2 + ((fv(2)-y0)/xy_err)^2;

diff=diff/numel(starmat);

