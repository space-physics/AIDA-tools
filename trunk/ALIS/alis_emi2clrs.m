function [clrs] = alis_emi2clrs(filter)
% ALIS_EMI2CLRS - convert ALIS emission  to rgb colour
%
% Calling:
%  [clrs] = alis_emi2clrs(filter)
% 
% Input:
%   FILTER - alis filter index, hopefully accepts the different
%   formats 
%
% Output:
%   CLRS - scaling factors between the different RGB-chanels


%   Copyright © 20050112 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%        A-em A-fc nm-e  fnr(typical)
green = [5577 5590 557.7  0];
red =   [6300 6310 630.0  1];
ir =    [8446 8455 844.6  4];
blue =  [4278 4280 427.8  5];

f_diff(1) = min(abs(filter-green))/(filter+2*eps);% To avoid division-by-zero
f_diff(2) = min(abs(filter-red))/(filter+2*eps);
f_diff(3) = min(abs(filter-ir))/(filter+2*eps);
f_diff(4) = min(abs(filter-blue))/(filter+2*eps);

[f_d_min,best_filter] = min(f_diff);

clrs = [0 0 0];

if min(f_diff) < 0.1
  
  switch best_filter
   case 1 % green line
    clrs = [0 1 0];
   case 2
    clrs = [1 0 0];
   case 3
    clrs = [0.8 0 0.1];
   case 4
    clrs = [0 0 1];
   otherwise
    
    % All f_diff > .1 not really close to any well known filter
    % do no coloring and return gray image.
    
  end
  
end
