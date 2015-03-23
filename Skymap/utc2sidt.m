function [sidtime] = utc2sidt(date,utc)
% UTC2SIDT calculates the sidereal time.
%
% Calling:
% [sidtime] = utc2sidt(date,utc)
%
% Takes date and utc as argument.
% date(1) - the year ( 1995 - 95 )
% date(2) - month
% date(3) - day nr in month
% utc(1)  - hh
% utc(2)  - mm
% utc(3)  - ss.ms


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

jd = date2juldate( date );
T = ( jd - 2415020 ) / 36525;

qw = .27691398 + 100.00219359 * T + 0.000001075*T^2;

% Sidereal time at 0 UT.
sidtime = 24 * ( qw - floor( qw ) );

ut = utc(1) + utc(2)/60 + utc(3)/3600;

sidtime = sidtime + ut * ( 3/60 +57/3600 )/24 + ut ;

while ( sidtime > 24 )
  sidtime = sidtime - 24;
end
