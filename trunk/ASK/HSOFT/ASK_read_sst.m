function [mjs1,mjs2] = ASK_read_sst(a,FormatStr)
% ASK_READ_SST -  A procedure to read the start and stop times from a string 
% used for the lookup table reads.
% i.e. Converts '31/03/2009 15:47:09 01/04/2009 09:31:21'
% to two mjs values (mjs1 and mjs2)
%
% Calling:
%   [mjs1,mjs2] = ASK_read_sst(A,FormatStr)
% Input:
%  A - a string/char array with date and time information for 2
%      times, it has to contain 2 full date-time times (Y, M, D, h,
%      m, s)
%      corresponding to the format string FormatStr, default:
%      '%d/%d/%d %d:%d:%f %d/%d/%d %d:%d:%f', which obviously
%      corresponds to
%      D1/M1/YYY1 H1:M1:S1.ms D2/M2/YYY2 H2:M2:S2.ms 
% 
%  FormatStr - (Optional) format string describing how to parse
%              date and time out from A
% Output:
%  MJS1 - Time in modified Julian seconds of first date in A

% Modified from read_sst.pro
% Copyright Bjorn Gustavsson 20110128
% GPL 3.0 or later applies


if nargin == 1 | isempty(FormatStr)
  FormatStr = '%d/%d/%d %d:%d:%f %d/%d/%d %d:%d:%f';
end

%[d1,m1,y1,H1,M1,S1,d2,m2,y2,H2,M2,S2] = strread('31/03/2009 15:47:09 01/04/2009 09:31:21','%d/%d/%d %d:%d:%d %d/%d/%d %d:%d:%d');
[d1,m1,y1,H1,M1,S1,d2,m2,y2,H2,M2,S2] = strread( a, FormatStr);

mjs1 = ASK_TT_MJS([d1,m1,y1,H1,M1,S1]);
mjs2 = ASK_TT_MJS([d2,m2,y2,H2,M2,S2]);
