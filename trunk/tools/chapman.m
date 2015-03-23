function [chpm_int] = chapman(I0,hmax,w0,h)
% CHAPMAN - gives the Chapman profile.
% 
% Calling:
%   chpm_int = chapman(I0,hmax,w0,h)
% Input: 
%   I0 - Max intensity
%   H0 - altitude of max intensity
%   W0 - width
%   H  - Altitude array.

%       Bjorn Gustavsson
%	Copyright © 1997 by Bjorn Gustavsson
%   This is free software, licensed under GNU GPL version 2 or later

if numel(w0) == 1
  
  hi = (h-hmax)./w0;
  chpm_int = 1*I0*exp(1-hi-exp(-hi));
  
elseif numel(w0) == 2
  
  h1 = (h-hmax)./w0(1);
  h2 = (h-hmax)./w0(2);
  hi = h1;
  hi(h>hmax) = h2(h>hmax);
  chpm_int = 1*I0*exp(1-hi-exp(-hi));
  
end
