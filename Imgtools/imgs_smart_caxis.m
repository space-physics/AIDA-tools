function cax = imgs_smart_caxis(alpha,varargin)
% imgs_smart_caxis - alpha-percentile setting of color-axis,
%   sets clims to [alpha,1-alpha] points of the cumulative
%   intensity distribution. Either called with intensity image
%   IMGS_SMART_CAXIS(ALPHA,I); or with a histogram
%   IMGS_SMART_CAXIS(ALPHA,B,X)
% 
% Calling:
% cax = imgs_smart_caxis(alpha,I)
% cax = imgs_smart_caxis(alpha,B,X)
%
% INPUT: 
%   ALPHA - percentile cut-off
% either
%   I - intensity image.
% or
%   B,X - histogram specification as output from HIST
% 
% OUTPUT
%   CAX - adjusted intensity limits.
%
% See also HIST


%   Copyright © 20050209 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if alpha >= .5; % otherwise...
  
  alpha = alpha/100;
  
end

if nargin == 2
  
  I = varargin{1};
  [b,x] = hist(I(:),unique(I(:)));
  
else
  
  b = varargin{1};
  x = varargin{2};
  
end

ch = cumsum(b)/sum(b);
% $$$ if length(alpha) == 1
i_cut = find(alpha(1) < ch & ch < 1-alpha(end));
% $$$ else
% $$$   i_cut = find(alpha(1) < ch & ch < 1-alpha(2));
% $$$ end

caxis(x(i_cut([1 end])));

if nargout == 1
  cax = caxis;
end
