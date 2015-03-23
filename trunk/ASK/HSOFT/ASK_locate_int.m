function [start_indx,stop_indx] = ASK_locate_int(t1,t2,mjs1,mjs2,hardBoundaries)
% ASK_LOCATE_INT - 
%   
% this procedure finds which of the intervals given by start and
% stop times t1 and t2 (arrays of mjs) overlap with the interval
% given by mjs1 and mjs2. t1 and t2 are time arrays - t1 is the
% start times for each file  (for example) and t2 is the stop times
% for each file. mjs1 and mjs2 are single values, and are the start
% and stop times of the period you are looking for. In the file
% example sta and sto are the indices for the first and last file
% you should read to get your data.
%
% t1, t2, mjs1, mjs2 are inputs.
% sta and sto are outputs.
%
% If the hardBoundaries keyword is set then greater than and less
% than conditions are used instead of "or equal to" versions.
% This prevents finding periods which are just touching the search
% period.
%
% This routine is usually used for searching lookup tables for the
% desired period. 
%
% indices of the first and last intervals are returned in
% START_INDX and STOP_INDX 
%
% Calling:
%   [start_indx,stop_indx] = locate_int(t1,t2,mjs1,mjs2,hardBoundaries)
% Input:
%   t1   - array of mega-block start times (in MJS)
%   t2   - array of mega-block end times (in MJS)
%   mjs1 - start time for interval 
%   mjs2 - end time for interval 
%   hardBoundaries - flag to set to 1 to make the search excluding
%                    the exact intervall end time.
% Output:
%   start_indx - start index
%   stop_indx  - end index

% Modified from locate_int.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


if nargin == 4 | isempty(hardBoundaries)
  hardBoundaries = 0;
end

start_indx = -1;
stop_indx = -1;

if hardBoundaries
  indx_inside = find(t1 < mjs2(1) & mjs1(1) < t2);
else
  indx_inside = find(t1 <= mjs2(1) & mjs1(1) <= t2);
end

if ~isempty(indx_inside)
  start_indx = indx_inside(1);
  stop_indx = indx_inside(end);
end
