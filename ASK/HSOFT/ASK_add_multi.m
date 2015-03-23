function img_out = ASK_add_multi(img_in)
% ASK_ADD_MULTI - Addmultiple frames
%   
% Calling:
%   img_out = ASK_add_multi(img_in)
% Input:
%   img_in - input image, array of arbitrary number of dimensions
% Output:
%   img_out - output image, average along third dimension of img_in

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


SZ = size(img_in);

if length(SZ) > 2
  img_out = squeeze(mean(img_in,3));
else
  img_out = img_in;
end
