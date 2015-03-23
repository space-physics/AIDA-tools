function imOut = imresize(imIn,imsizOut)
% IMRESIZE - binning/resizing of image.
%  Simplistic fall-back to Mathworks imresize function. This
%  version only handles resizing in even powers of 2 by binning of
%  the input image.
% 
% Calling:
%  imOut = imresize(imIn,imsizOut)
% Input:
%  imIn - input image [N1 x N2]
%  imsizOut - desired size of output image
% Output:
%  imOut - output image

imsizIn = size(imIn);

nrAddLoops = log2(imsizIn./imsizOut);

imOut = imIn;
for i1 = 1:nrAddLoops(1),
  imOut = imOut(1:2:end,:) + imOut(2:2:end,:);
end
for i1 = 1:nrAddLoops(2),
  imOut = imOut(:,1:2:end) + imOut(:,2:2:end);
end
