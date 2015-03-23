function [nearest_indx] = ASK_nearest_int(t1,mjs1)
% ASK_NEAREST_INT - finds the interval starting at t1 closest to mjs1
%   
% this procedure finds which of the intervals with starting times t1
% is closest to mjs1. t1 are a time arrays - t1 is the
% start times for each file  (for example). mjs1 are a single
% value, and are the start times of the period you are looking for. In the file
% example start_indx is the index for the closest entry in t1.
%
% t1, mjs1 are inputs.
% nearest_indx is the output.
%
% If the hardBoundaries keyword is set then greater than and less
% than conditions are used instead of "or equal to" versions.
% This prevents finding periods which are just touching the search
% period.
%
% This routine is usually used for searching lookup tables for the
% desired period. 
%
% indices of the nearest intervals are returned in
% NEAREST_INDX 
%
% Calling:
%   [start_indx] = ASK_nearest_int(t1,mjs1)
% Input:
%   t1   - array of mega-block start times (in MJS)
%   mjs1 - start time for interval 
% Output:
%   neaerest_indx - index to the entry in t1 closest to mjs1

% Modified from locate_int.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies



% start_indx = -1;
% stop_indx = -1;

[dt,nearest_indx] = min(abs(t1 - mjs1));

