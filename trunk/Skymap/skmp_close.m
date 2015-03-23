% SKMP_CLOSE - end the skymap session
%   



%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

close(SkMp.figsky)
if isfield(SkMp,'fig_spec')
  close(SkMp.fig_spec)
end
% $$$ clear SkMp plottstars infovstars possiblestars star_list ...
% $$$     staraz stardir starid starmagn starze stationpos stnnames ...
% $$$     updstrplstr 
