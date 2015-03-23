function [f,noise] = img_wiener2(varargin)
% IMG_WIENER2 - Lee's sigma-filter, local statistics filter
%  My implementation of mathworks wiener2, should be transparently
%  identical, and will use wiener2 if the image processing toolbox
%  is available.
% 
% Calling:
%  [Img_out] = img_wiener2(Img_in,[M,N],noise);
%  [Img_out] = img_wiener2(Img_in,[M,N]); % Noise will be estimated from average variance
%  [Img_out] = img_wiener2(Img_in);       % [M,N] will default to [3,3]
% Input:
%  Img_in - input image 2-D
%  region - [M,N] integers for the size of the N-by-M neighbourhood
%           to calculate the image mean and standard deviation over
%  noise - (optional) either scalar or same sized as IMG_IN
%          estimate of local variance
% Output:
%  Img_out - filtered version, same size as Img_in, always double.


%   Copyright © 2009 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


try
  [f,noise] = wiener2(varargin);
  return
catch
end

D = varargin{1};
if nargin > 1
  nhood = varargin{2};
else
  nhood = [3,3];
end
if nargin > 2
  noise = varargin{3};
else
  noise = [];
end

D_class = class(D);
if ~isa(D, 'double')
  D = im2double(D);
end

% Estimate the local mean of f.
localMean = filter2(ones(nhood), D) / prod(nhood);

% Estimate of the local variance of f.
% Var = <Y^2> -<Y>^2
localVar = filter2(ones(nhood), D.^2) / prod(nhood) - localMean.^2;

% Estimate the noise power if necessary.
if (isempty(noise))
  noise = mean(localVar(:));
end

% Compute result
f = localMean + (max(0, localVar - noise) ./ ...
                 max(localVar, noise)) .* (D - localMean);
