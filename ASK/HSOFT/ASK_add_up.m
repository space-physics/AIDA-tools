function [img_out,std_img_out] = ASK_add_up(imgs_in,alpha,filename)
% ASK_ADD_UP - Alpha-trimmed temporal average of data block
%   
% Calling:
%   [img_out,std_img_ut] = ASK_add_up(imgs_in,alpha,filename)
% Input:
%   imgs_in - data block to be processed, alpha-trimmed average is
%            done on third dimension. Size: [ Ny, Nx, Nt, Nextras...]
%   alpha - fraction of pixels to trim away, should be in range 
%           [0 - 1/2], if outside it will be adjusted, if 1/2
%           median along third dimension is returned. Defaults to
%           0.1 if empty or ADD_UP is called whit 1 argument.
%   filename - filename to store the average in, will be stored in 
%              fullfile(HDIR,'calibration','files',filename) - that
%              is HDIR/calibration/files/filename
% Output:
%   img_out - alpha-trimmed image. Sized [ Ny, Nx, 1, Nextras] or
%             with matlabs auto-shrinking of trailing dimensions
%             [Ny, Nx] if imgs_in is a 3-D array.
%   std_img_out - standard deviation of the 1-2*alpha-included
%                 pixels. 
% Needs HDIR to know where to save data...

% Modified from add_up.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs

% Get size of input image block
SZ = size(imgs_in);

if length(SZ) == 2
  
  % If the number of dimensions is 2 - function is called with just 1
  % frame, then do nothing:
  img_out = imgs_in;
  std_img_out = 0*imgs_in;
  
else
  
  if nargin == 1 | isempty(alpha)
    % Get alpha, either default 0.1
    alpha = 0.1;
  else
    % Or supplied - make sure it is in [0 - 1/2]
    alpha = max(0,min(1/2,alpha));
  end
  if alpha == 1/2;
    % if it is 1/2 - then just return the median along the third
    % dimension
    img_out = median(imgs_in,3);
    std_img_out = std(imgs_in,3);
  else
    % Otherwise sort and trim away the right number of outliers
    nAlpha = max(1,SZ(3)*alpha);
    img_tmp = sort(imgs_in,3);
    img_tmp = img_tmp(:,:,(nAlpha+1):(end-nAlpha));
    img_out = mean(img_tmp,3);
    std_img_out = std(img_tmp,3);
  end

end

if nargin > 2
  % If filename is given try to write output image to file:
  fp = fopen(fullfile(vs.HDIR,'calibration','files',filename),'w');
  if fp > 0
    
    fwrite(fp,img_out,'double')
    
  end
  fclose(fp);
  
end
