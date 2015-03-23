function [SkMp] = updrmstar(SkMp)
% UPDRMSTAR - Callback function removing a selected star
%   from the identified stars.
% 
% Calling:
%   [SkMp] = updrmstar(SkMp)
% Input:
%   SkMp - starcal struct
% Output:
%   SkMp - starcal struct

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

button = 1;

figure( SkMp.figsky )

while ( button == 1 | lower(char(button)) == 'l')
  
  [x0,y0,button] = ginput(1);
  findneareststarxy(x0,y0,SkMp);
  title('Retry (l) | Quit (m) | Remove (r)')
  
  [x1,y1,button] = ginput(1);
  if ( button == 3 | lower(char(button)) == 'r' )
    
    diff = ( SkMp.identstars(:,3) - x0 ).^2 + ...
           ( SkMp.identstars(:,4) - y0 ).^2;
    [mindiff,minindex] = min(diff);
    SkMp.identstars(minindex,:) = [];
    if isfield(SkMp,'last_pH')
      delete(SkMp.last_pH)
    end
  end
  
end
title('')
