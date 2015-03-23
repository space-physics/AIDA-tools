function [img,clrs] = alis_img2rgb(img_in,filter,I_lims)
% ALIS_IMG2RGB - convert intensity image to rgb image
%
% Calling:
%  img = alis_img2rgb(img_in,filter)
%  img = alis_img2rgb(img_in,filter,Intensity_limits)
% 
% Input:
%   IMG_IN - ALIS image.
%   FILTER - alis filter index, hopefully accepts the different
%   formats that have been used.
%
% Output:
% IMG - rgb image,
% CLRS - scaling factors between the different chanels


%   Copyright © 20050112 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%        A-em A-fc nm-e  fnr
green = [5577 5590 557.7  0];
red =   [6300 6310 630.0  1];
ir =    [8446      844.6  4];
blue =  [4278      427.8  5];

f_diff(1) = min(abs(filter-green))/(filter+2*eps);% Avoid divide-by-zero
f_diff(2) = min(abs(filter-red))/(filter+2*eps);
f_diff(3) = min(abs(filter-ir))/(filter+2*eps);
f_diff(4) = min(abs(filter-blue))/(filter+2*eps);

[f_d_min,best_filter] = min(f_diff);
% scale the image to be between 0-1
if nargin < 3
  img = ( img_in - min(img_in(:)) )/( max(img_in(:)) - min(img_in(:)) );
else
  img = max(min(img_in,I_lims(2)),I_lims(1));
  img = ( img - I_lims(1) )/abs(diff(I_lims));
end
img = repmat(img,[1 1 3]);
clrs = [0 0 0];

if min(f_diff) < 0.1
  
  switch best_filter
   case 1 % green line
    img(:,:,[1 3]) = 0; % r,g,b=0;
    clrs = [0 1 0];
   case 2 % red line
    img(:,:,[2 3]) = 0; % r,g=0,b=0;
    clrs = [1 0 0];
   case 3 % 8446 - infrared
    img(:,:,2) = 0; % ir r*.8,g=0,b*.1
    img(:,:,1) = 0.8 * img(:,:,1);
    img(:,:,3) = 0.1 * img(:,:,3);
    clrs = [0.8 0 0.1];
   case 4 % 4278 - blue
    img(:,:,[1 2]) = 0; % r=0,g=0,b;
    clrs = [0 0 1];
   otherwise
    
    % All f_diff > .1 not really close to any well known filter
    % do no coloring and return gray image.
    
  end
  
end
