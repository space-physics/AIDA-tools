function [jd] = date2juldate(date)
% DATE2JULIANDATE calculates the julian date at 0h UT
%
% Calling:
% [jd] = date2juldate(date)
%
% It takes input date as an array with date(1) <-> the year ( 95 -> 1995 )
%                                      date(2) <-> month
%                                      date(3) <-> day nr in month


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ( date(1) < 100 )
  year = date(1) + 1900;
else
  year = date(1);
end
month = date(2);
day = date(3);

if ( month >= 3 )
  f = year;
else
  f = year-1;
end

if ( month >= 3 )
  g = month;
else
  g = month+12;
end

a = 2 - floor(f/100)+floor(f/400);

jd = floor( 365.25*f ) + floor( 30.6001*(g+1) ) + day + a + 1720994.5;
