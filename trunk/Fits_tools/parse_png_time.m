function [my, mm, md, mh, mmin, ms] = parse_png_time(time)
% PARSE_PNG_TIME - parse miracle png time
% SYNOPSIS
%   [my, mm, md, mh, mmin, ms] = parse_png_time(time)
%
% DESCRIPTION
%   time must be in format yyyy-mm-ddHH:MM:SS.FF milliseconds are 
%   indicated as fractions of seconds, AND MUST BE INCLUDED. 
%   in more practical terms, the time string is 21 characters long.
%   the time string IS 21 characters long and in the format
%   described above.
%

my   = double(str2double(time(1:4)));
mm   = double(str2double(time(6:7)));
md   = double(str2double(time(9:10)));
mh   = double(str2double(time(11:12)));
mmin = double(str2double(time(14:15)));
ms   = double(str2double(time(17:21)));
