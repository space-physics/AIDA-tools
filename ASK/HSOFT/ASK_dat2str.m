function str = ASK_dat2str(MJS,FormatNrOrStr)
% ASK_DAT2STR - convert a modified Julian second (mjs) to date string
%   
% Calling:
%   str = dat2str(MJS,FormatNrOrStr)
% Input: 
%   MJS - array with times in modified Julian seconds (since 1950/1/1-00:00)
%   FormatNrOrStr - format identifier/number or free format string,
%                   see DATESTR for details. (optional, if left out
%                   format yyyy/mm/dd-HH:MM:SS.FFF will be used, 31
%                   is a good option, 30 is ISO 8601)

% Modified from dat2str.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


if nargin == 1
 FormatNrOrStr = 'yyyy/mm/dd-HH:MM:SS.FFF';
end
% let Matlab date-functions do the job:
str = datestr(MJS/(24*3600)+datenum([1950,1,1]),FormatNrOrStr);
