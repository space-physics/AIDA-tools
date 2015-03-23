function i1 = ASK_time2indx(timevec)
% ASK_TIME2INDX - returns the imasge index for a time-vector
%
% Calling:
%   indx = ASK_time2indx([yyyy, mm, dd, hh, mm, ss])

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies
global vs

% Seconds since 1950-01-01 00:00:00 of the time of interest
TT_MJS = ASK_time2MJS(timevec);
% Seconds since 1950-01-01 00:00:00 of the first frame in current mega-block
Tstart = ASK_time_v(1,1);
% Seconds since 1950-01-01 00:00:00 of the last frame in current mega-block
Tend = ASK_time_v(vs.vnl(vs.vsel),1);

if Tstart <= TT_MJS & TT_MJS <= Tend
  % This should be the closest index if I didn't subtract 2
  i1 = round((TT_MJS-vs.vmjs(vs.vsel))/vs.vres(vs.vsel))-2;
  % But this is not that much slower when we want to be sure that
  % we get the frame just before TIMEVEC - avoiding goofs due to
  % rounding:
  while i1 <= vs.vnl(vs.vsel) & ASK_time_v(i1+1,1) < TT_MJS
    i1 = i1 + 1;
  end
  
else
  i1 = [];
  disp(['Warning. time: ',datestr(timevec,'yyyy/mm/dd HH:MM:SS.FFF'),' is not found between: ',ASK_dat2str(ASK_time_v(1,1)),' and: ',ASK_dat2str(ASK_time_v(vs.vnl(vs.vsel),1))])
end
