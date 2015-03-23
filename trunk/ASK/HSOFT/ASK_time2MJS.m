function TT_MJS = ASK_time2MJS(date_vec)
% ASK_time2MJS - converts calendar date to modified Julian second
%   (seconds elapsed since 00:00 UT on Jan 1, 1950)
%
% Calling: 
%   MJS_time = ASK_time2MJS(date_vec)
% Input:
%   date_vec - array with rows of: [yyyy,mm,dd,(hh,mm,ss.ms)]
% Output:
%   MJS_time - seconds since 00:00 UT on Jan 1, 1950

% Modified from TT_MJS.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

% Let mathworks date-functions do the heavy lifting:
TT_MJS = (double(datenum(date_vec)) - double(datenum([1950,1,1])))*24*3600;
