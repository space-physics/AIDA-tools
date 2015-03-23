function time_V = ASK_indx2datevec(indx)
% ASK_INDX2DATEVEC - Convert a frame index into a [yyyy,mm,dd,HH,MM,SS.FFF]
%   array.
% 
% Calling:
%  time_v = ASK_indx2datevec(indx)
% Input:
%  INDX - Frame index
% Output:
%  TIME_V - [yyyy, mm, dd, HH, MM, SS.fff] array with date and time
%           corresponding to the frame index INJDX

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

time_V = str2num(ASK_dat2str(ASK_time_v(indx,1),'yyyy mm dd HH MM SS.FFF'));
