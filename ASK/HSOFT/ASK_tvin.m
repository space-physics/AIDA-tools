function h = ASK_tvin(img_in,trueRGB)
% ASK_tvin - display an image
%
% Calling:
%   h = ASK_tvin(img_in,trueRGB)
% 
% Original comment from tvin.pro:
% ASK_TVIN -  Output the image in the current axes.
% Equivalent of tv, but scales the image into !p.position.
% Set true keyword if the array is a colour image.
% Array is the imput image array.
% This didn't seem to work with x windows, so Dan fixed it
% 03/08/2006

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

H = imagesc(img_in);axis xy
if nargout > 0
  h = H;
end

