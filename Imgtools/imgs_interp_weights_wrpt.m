function [weights,indxes] = imgs_interp_weights_wrpt(times,t0)
% IMGS_INTERP_WEIGHTS_WRPT - linear interpolation weights at T0
% relative to TIMES. 
% 
% Calling: [weights,indxes] = imgs_interp_weights_wrpt(times,t0)
% 
% Input:
%  times - time of of known data [nx1] or [1xn], should be sorted.
%  t0    - time for which to get linear interpolation weights [scalar]. 
% 
% Output:
%  weights - interpolation weight
%  indxes - index to the nearest smaller and larger elements in times



%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

[min_dT,indx_thisT] = min(abs(times-t0)); % 1 The time closest to t0

dt = (t0-times(indx_thisT));% 2 The time to t0
indx_nnT = indx_thisT+sign(dt);                 % 3 index to point on the "other side of t0"
dt = dt/diff(times(sort([indx_thisT indx_nnT])));


weights = [1-abs(dt) abs(dt)];
indxes = [indx_thisT indx_nnT];
