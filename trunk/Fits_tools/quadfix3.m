function [img_out] = quadfix3(img_in,strips,stripsize)
% QUADFIX3 quadrant balancing of raw CCD data from overscan-strips 
%
% Calling
% [img_out] = quadfix(img_in,stripsize)
% 
% Input:
%   IMG_IN - input image with overscan strips with shift of
%   zero-level 
%   STRIPS - 2 for two overscanstips - at the left and right edge
%            of image, 1 for one at left edge of image.
%   STRIPSIZE - size of overscanestrip in pixels.
%   QUADFIX3 reduces the median value of the overscanpixels from
%   each line.
%
% See also REMOVERSCANSTRIP



%   Copyright © 1998 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

img_out = img_in;

if ( strips == 2 )

  if ( stripsize > 1 )
    
    k1 = median(img_in(:,1:stripsize),2);
    k2 = median(img_in(:,end-stripsize+1:end),2);
    
  else
    
    k1 = img_in(:,1)';
    k2 = img_in(:,end)';
    
  end
  
  for i1 = 1:length(k1)
    
    img_out(i1,1:end/2) = img_out(i1,1:end/2)-k1(i1);
    img_out(i1,end/2+1:end) = img_out(i1,end/2+1:end)-k2(i1);
    
  end
  
elseif ( strips == 1 )
  
  k1 = median(img_out(:,1:stripsize),2);
  for i1 = 1:length(k1)
    
    img_out(i1,:) = img_out(i1,:)-k1(i1);
    
  end

else
  
  k2 = median(img_out(:,end-stripsize+1:end),2);
  
  for i1 = 1:length(k2)
    
    img_out(i1,:) = img_out(i1,:)-k2(i1);
    
  end
  
end
