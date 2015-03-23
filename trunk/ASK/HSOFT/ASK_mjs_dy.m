function date_out = ASK_mjs_dy(MJStime)
% ASK_MJS_DY -  convert mjs time to decimal years
%   
% Calling:
%   date_out = ASK_mjs_dy(MJStime)
% Input:
%   MJStime - time in modified Julian second (since 1950 1 1 00:00)
%             Currently only functioning for scalar MJStime
% Output:
%   date_out - date in fractional years

% Written to mimic MJS_TT.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

isodd = @(x) mod(x,2);
isleap = @(x) isodd(sum(0 == mod(x, [4 100 400 4000])));
% Leap years are years evenly divisible with 4 and 400, but not 100
% or 4000 - now 4000 I personally dont think I'll need to worry
% about, but such an attitude is what put people's knickers in such
% a twist in the late 1990s...

% Convert date to year et al:
[yr,mo,da,hr,mi,se] = ASK_MJS_TT(MJStime);
% Calculate MJS-time of first of January that year
[mjsYearstart] = ASK_TT_MJS([yr,1,1,0,0,0]);
% Day number of the date is difference in number of seconds divided
% by 3600*24...
dayNR = ( MJStime -  mjsYearstart )/3600/24;
% Date of date as fractional year
date_out = yr + dayNR/(365 + double(isleap(yr)));
