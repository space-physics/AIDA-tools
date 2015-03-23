function img_out = ASK_binning(img_in,binningFactors)
% ASK_BINNING - Post-bin data
%   
% Calling:
%   img_out = ASK_binning(img_in,binningFactors)
% Input:
%   img_in  - Input image to be binned [Ny x Nx x Nt]
%   binningFactors - [Bx, By]
% Output:
%   img_out - rebinned output image  [Ny/By x Nx/Bx x Nt]
% 
% Function to return a binned copy of the data sequence IN_IMG.
% IN_IMG is the data sequence, for example as returned by READ_MV.
% It can have three dimensions, in which case THIRD should be time,
% second image x coordinate, and first image y coordinate. Alternately it
% can be a single image, with two dimensions only.
% binning should be a two element array, with the binning size, e.g. [2,2]
% for 2x2 binning. The first element is the x binning, and the second is
% the y binning.
% e.g. IMG_OUT = ASK_binning(IMG_IN,[2,2]);
% Note the pixel mean is returned, not the pixel total! This is so the
% calibration remains valid.


% Modified from bin.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies


sz_out = size(img_in); % Size of input image

if any(mod(size(img_in),binningFactors([2,1])))
  img_out = img_in;
  disp(['Warning, no binning done, image size (',num2str(sz_out),') not evenly divisible by binning factors!'])
  return
end
sz_out(1:2) = sz_out(1:2)./binningFactors([2,1]); % Size of output image

img_out = zeros(sz_out);


% Loop over the necessary shifts along dimension #1
for i1 = 0:(binningFactors(2)-1),
  % and over the necessary shifts along dimension #2
  for i2 = 0:(binningFactors(1)-1),
    % Add the shifted pixel intensities
    img_out = img_out + img_in((1+i1):binningFactors(2):end,...
                               (1+i2):binningFactors(1):end,...
                               :);
  end
end

% and divide by the number of pixels added
img_out = img_out/prod(binningFactors);
