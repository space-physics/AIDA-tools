function [I_ts] = imgs2timeserieses(files,U,V)
% imgs2timeserieses - make time-series for selected pixels
% Calling:
%  [I_ts] = imgs2timeserieses(files,U,V)
% 
%   See also: INIMG, STARCAL, TYPICAL_PRE_PROC_OPS


%   Copyright © 20100112 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


wbh = waitbar(0);
nfiles = size(files,1);
for i1 = nfiles:-1:1,
  
  [data] = imread(files(i1,:));
  data = sum(data,3);
  medfilt2(medfilt2(data,[3,3]),[3,3]);
  if length(size(data)) == 2
    I_ts(i1,:) = interp2(data,U(:),V(:));
  elseif length(size(data)) == 3
    I_ts(i1,:) = interp2(sum(data,3),U(:),V(:));
  end
  if rem(i1,20) == 0
    waitbar((nfiles - i1)/nfiles,wbh)
  end
end
close(wbh)
