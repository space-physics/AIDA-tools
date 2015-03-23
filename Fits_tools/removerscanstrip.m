function img_out = removerscanstrip(in_img,strips,stripsize)
% REMOVERSCANSTRIP - removes overscan-strips from raw CCD data
%
% Calling:
% img_out = removerscanstrip(in_img,strips,stripsize)
%
% Input:
%   IMG_IN - input image with overscan strips with shift of
%   zero-level 
%   STRIPS - 2 for two overscanstips - at the left and right edge
%            of image, 1 for one at left edge of image.
%   STRIPSIZE - size of overscanestrip in pixels.
%
% See also QUADFIX3


%   Copyright © 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ( strips == 2 )
  
  img_out = in_img(:,stripsize+1:end-stripsize);
  
elseif ( strips == 1 )
  
  img_out = in_img(:,stripsize+1:end);
  
else
  
  img_out = in_img(:,1:end-stripsize);
  
end
