function TT_MJS = ASK_TT_MJS(date_vec)
% ASK_TT_MJS - converts calendar date to modified Julian second
%   (seconds elapsed since 00:00 UT on Jan 1, 1950)
%
% Calling: 
%   TT_MJS = ASK_TT_MJS(date_vec)
% Input:
%   date_vec - array with rows of: [yyyy,mm,dd,(hh,mm,ss.ms)]
% Output:
%   TT_MJS - seconds since 00:00 UT on Jan 1, 1950


% Modified from TT_MJS.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies

% Let mathworks date-functions do the heavy lifting:
TT_MJS = (double(datenum(date_vec)) - double(datenum([1950,1,1])))*24*3600;
