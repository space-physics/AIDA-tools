function img_out = img_rot(img_in,angle,x0,y0,method,extrapval)
% IMG_ROT - rotate image around arbitrary point.
% 
% Calling:
%  img_out = img_rot(img_in,angle,x0,y0,method,extrapval)
% Input:
%  img_in    - input image [N x M] (double)
%  angle     - rotation angle in degrees (anti-clockwise)
%  x0        - horizontal coordinate to rotate around (pixel #),
%              defaults to size(img_in,2)/2
%  y0        - vertical coordinate to rotate around (pixel #),
%              defaults to size(img_in,1)/2
%  method    - interpolation method [{'*linear'} | '*spline' |
%              '*cubic' | '*nearest'], the starred versions is
%              faster but the "unstared" versions will also work.
%  extrapval - value to use for regions that fall outside the
%              rotated image, defaults to Nan.
% Output:
%  img_out   - rotated version of img_in [N x M]
% 
% Example:
%   Im1 = rand(123,321);
%   rAngle = -25;
%   x0 = 54;
%   y0 = 65;
%   method = '*spline';
%   extrapval = 0;
%   Im2 = img_rot(Im1,rAngle,x0,y0,method,extrapval);

% Copyright � Bjorn Gustavsson 20110318
% GNU copyleft 3.0 or later applies


% get size of input image
[sy,sx] = size(img_in);

% Set the defaults for x0, y0 method and extrapval
if nargin < 3 || isempty(x0)
  x0 = sx/2;
end
if nargin < 4 || isempty(y0)
  y0 = sy/2;
end
if nargin < 5 || isempty(method);
  method = '*linear';
end
if nargin < 5 || isempty(extrapval);
  extrapval = 0;
end

%imrotateOK = 0;
%% If only image and rotation angle then try imrotate
%if nargin == 2 & mod(angle,90) == 0
%  try
%    img_out = imrotate(img_in,angle);
%    imrotateOK = 1;
%  catch
%    imrotateOK = 0;
%  end
%end
%% if that didnt work out do-it-yourself:
%if imrotateOK == 0 % still not done!

% make the rotated grid
[x,y] = meshgrid(1:sx,1:sy);
xi = (x-x0)*cos(angle*pi/180) + -(y-y0)*sin(angle*pi/180)+x0;
yi = (x-x0)*sin(angle*pi/180) +  (y-y0)*cos(angle*pi/180)+y0;

% Interpolate to get the rotated image intensities:
img_out = interp2(img_in,xi,yi,method,extrapval);

%end
%keyboard
