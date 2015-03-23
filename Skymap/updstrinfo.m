function [SkMp,staraz,starze,starid,starmagn,thisstar] = updstrinfo(SkMp)
%
% UPDSTRINFO - function that handles the callback from
% 'star/information' and displays the information about the star.
%

%   Copyright © 19990222 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

figure( SkMp.figsky )

%[x0,y0,button] = ginput(1);
[x0,y0] = ginput(1);
if isempty(SkMp.img)
  
  [staraz,starze,starid,starmagn] = findneareststar(x0,y0,SkMp);
  
else
  
  [staraz,starze,starid,starmagn] = findneareststarxy(x0,y0,SkMp);
  
end
disp(' ')
disp(SkMp.star_list(starid))
thisstar = SkMp.star_list(starid);
