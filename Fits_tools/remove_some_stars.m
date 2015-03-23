function img_out = remove_some_stars(img_in,time,pos,optpar,remove_these_stars,size_r_t_s)
% REMOVE_SOME_STARS - Remove bright stars from images,
%   The bright star spot is replaced by the average in the
%   surrounding frame. Usefull for removal of stars that are to big
%   or bright to be efficiently removed with 2-D median-filter.
% 
% Calling:
%   img_out = remove_some_stars(img_in,time,pos,optpar,remove_these_stars,size_r_t_s)
%
% Input:
%   IMG_IN - image with annoying bright stars.
%   TIME - Date and UT-time of observation [YYYY, MM, DD, hh, mm, ss.xx]
%   POS - Latitude and longitudee of observations site (degrees)
%   OPTPAR - Optical parameters that describe the optics and rotation
%            of the camera,
%   REMOVE_THESE_STARS - Star-catalog entries of stars to remove.
%   SIZE_R_T_S - size of region to be replaced with average of
%                surrounding frame.
% Output:
%   IMG_OUT - image after removal of bright stars.


%   Copyright © 20061004 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bxy bx by

if nargin > 5
  
  dl = size_r_t_s;
  
else
  
  dl = 1;
  
end

img_out = img_in;
if ~isempty(remove_these_stars)
  
  bxy = size(img_out);
  bx = bxy(1);
  by = bxy(2);
  % Calculate the sky positions of the stars to mask out:
  [az,ze] = starpos2(remove_these_stars(:,1),...
                     remove_these_stars(:,2),...
                     time(1:3),...
                     time(4:6),...
                     pos(2),...
                     pos(1));
  
  % and their image positions:
  if isstruct(optpar)
    [ua,wa] = project_directions(az',ze',optpar,optpar.mod,bxy);
  else
    [ua,wa] = project_directions(az',ze',optpar,optpar(9),bxy);
  end
  ua = round(ua);
  wa = round(wa);
  iu = find(inimage(ua-4,wa-4,bx-7,by-7));
  
  for i = 1:length(iu),
    % Get the image reagion around each star position
    wreg1 = max( min( wa(iu(i))-dl:wa(iu(i))+dl, bx), 1);
    ureg1 = max( min( ua(iu(i))-dl:ua(iu(i))+dl ,by) ,1);
    wreg2 = max( min( wa(iu(i))-(dl+1):wa(iu(i))+(dl+1), bx), 1);
    ureg2 = max( min( ua(iu(i))-(dl+1):ua(iu(i))+(dl+1) ,by) ,1);
    A_diff = length(ureg2)*length(wreg2) - length(ureg1)*length(wreg1);
    
    %if we have inpaint_nans
    if exist('inpaint_nans','file')
      % then we can simply set that image region to NAN
      img_out(wreg1,ureg1) = nan;
    else
      % Otherwise we just set the pixel intensities to the average
      % of the intensities in the surrounding frame:
      img_out(wreg1,ureg1) = (sum(sum(img_out(wreg2,ureg2)))-...
                              sum(sum(img_out(wreg1,ureg1))))/A_diff;
    end
    
  end
  
end

try
  % If we had INPAINT_NANS then we should just use that to obtain a
  % smoother intensity mask:
  img_out = inpaint_nans(img_out,4);
catch
  % no luck this time around...
end
