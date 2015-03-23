function img_out = interference_rem_auto(img_in,if_level,method,wpsm)
% INTERFERENCE_REM_RAUTO - automatic high frequency interference reduction
%   (Still in kind of experimental stage.)
%
% Calling:
% img_out = interference_rem_rauto(img_in,if_level)
%
% INPUT:
%   IMG_IN - 2-D array (double) with image containing interference
%            patterns. This method works for high frequency
%            patterns. Very low frequency patterns are poorly
%            identified. This is because the method relies on that
%            the fourier transform of a wienerfiltered IMG_IN has
%            supressed the interference pattern with a factor
%            IF_LEVEL.
%   IF_LEVEL - cut off level of interference pattern. Fourier terms
%              for which fft(IMG_IN)./wiener2(IMG_IN,WPSM) >
%              IF_LEVEL are removed.
%   METHOD - scaling method for the interference pattern. 
%            [{'flat'}|'interp','weighted']
%   WSPM - window size for wiener2-pre-filtering - [nx ny]



%   Copyright © 20050120 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin < 4 || isempty(wpsm)

  wpsm = 3;
  
end

if nargin < 3
  
  method = '';
  
end

% Fourier transform of image with interference pattern
fftd = fft2(img_in);
% Fourier transform of wiener filtered image. This at least reduces
% really high frequencies well; possibly we should have some
% adjustable parameter for the filter width
fftwd = fft2(img_wiener2(img_in, wpsm.*[1,1]));

% Find the fourier components that are bigger in fftd than in
% fftwd. Maybe the cascading filter is no so needed here?
%[i,j] = find(wiener2(medfilt2(abs(fftd)./abs(fftwd),[3 3]),[3 3]) > if_level);
%[i,j] = find(wiener2(abs(fftd)./abs(fftwd),[3 3]) > if_level);
[i,j] = find((abs(fftd)./abs(fftwd)) > if_level);
% Three parameters out instead? Is that faster

if isempty(i)
  img_out = img_in;
  return
end
% Make linear index out of i,j
indx = sub2ind(size(img_in),i,j);

if strcmp(method,'test')
  
  hold off
  imagesc(img_wiener2(abs(fftd)./abs(fftwd),[3 3]))
  caxis([0 if_level])
  hold on
  disp('push any key')
  pause
  plot(j,i,'w.')
  hold off
  
end
% Put the interference frequency pattern into fftwd (saving space,
% helping speed)
fftwd = 0*fftwd;
fftwd(indx) = fftd(indx);

% Calculate the real interference pattern
fftwd = real(ifft2(fftwd));
w = 1;
% A weighted version of the interference patter that shold minimize
% the variance of the filtered image, according to Gonzales and
% Woods.
if strcmp(method,'weighed')
  
  blksiz = 64;
  if min(size(img_in)) <= 128
    blksiz = 32;
  end
  w = ( blkproc(img_in.*fftwd,blksiz*[1 1],'mean(x(:))') - ...
        blkproc(img_in,blksiz*[1 1],'mean(x(:))').*...
        blkproc(fftwd,blksiz*[1 1],'mean(x(:))') )./ ...
      ( blkproc(fftwd,blksiz*[1 1],'mean(x(:).^2)') - ...
        blkproc(fftwd,blksiz*[1 1],'mean(x(:))').^2);
  indxx = sort(repmat(1:size(w,2),[1 blksiz]));
  indxy = sort(repmat(1:size(w,1),[1 blksiz]));
  
  w = w(indxx(:),indxy(:));
  
end
% filtered version of the weighting above making the relative
% scaling of the interference pattern vary smootly instead of
% stepwise from tile to tile.
if strcmp(method,'interp')
  
  blksiz = 64;
  if min(size(img_in)) <= 128
    blksiz = 32;
  end
  w = ( blkproc(img_in.*fftwd,blksiz*[1 1],'mean(x(:))') - ...
        blkproc(img_in,blksiz*[1 1],'mean(x(:))').*...
        blkproc(fftwd,blksiz*[1 1],'mean(x(:))') )./ ...
      ( blkproc(fftwd,blksiz*[1 1],'mean(x(:).^2)') - ...
        blkproc(fftwd,blksiz*[1 1],'mean(x(:))').^2);
  indxx = sort(repmat(1:size(w,2),[1 blksiz]));
  indxy = sort(repmat(1:size(w,1),[1 blksiz]));
  
  w = w(indxx(:),indxy(:));
  fltk = ones(blksiz)/blksiz^2;
  w = filter2(fltk,w,'same');
  
end

img_out = img_in-w.*fftwd;
