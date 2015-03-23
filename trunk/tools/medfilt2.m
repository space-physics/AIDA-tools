function outM = medfilt2(inM,fc,varargin)
% MEDFILT2 - 2 dimensional sliding median filter
%   Not really, rather an approximation with repeated use of 1-D
%   sliding median filter:
%   medfilt1(medfilt1(inM',filtersize2)',filtersize(2))
%   Working QD-solution for people without the image processing
%   toolbox. This is a fall-back routine that will be used when the
%   signal processing toolbox is installed but not the image
%   processing TB. When both are absent the gen_susan filter is
%   used as a last ditch save attempt.
%
% Calling:
% outM = medfilt2(inM,fc);
%
% See also MEDFILT1

% Copyright Bjorn Gustavsson 20050110
%   This is free software, licensed under GNU GPL version 2 or later

if nargin==1
  fc = [3 3];
end
try
  if length(fc) > 1
    outM = medfilt1(medfilt1(inM',fc(2))',fc(1));
  else
    outM = medfilt1(medfilt1(inM',fc)',fc);
  end
catch
  % The last resort, not a 2-D median filter but similar enough
  g_opts = gen_susan;
  w = ones(fc);
  w = w/sum(w(:));
  outM = gen_susan(inM,w,g_opts);
  
end
