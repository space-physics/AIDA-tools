function poschoice(SkMp)
% POSCHOICE - short function that updates the GUI windows
% made by checkok
%
% "Private" function, called through skymap/starcal GUI.
% 
% Calling:
% poschoice(SkMp)
% 
% See also CHECKOK

%   Copyright © 20010331 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

pos1 = get(SkMp.ui81,'Value');

if ( pos1 <= length(SkMp.longlat) )
  
  set(SkMp.ui815,'String',num8str(SkMp.longlat(pos1,1)));
  set(SkMp.ui816,'String',num8str(SkMp.longlat(pos1,2)));
  
end
