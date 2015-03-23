function SkMp = upddellastr(SkMp)
% UPDDELLASTR - 
%   

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ~isempty(SkMp.identstars) 
  
  SkMp.identstars = SkMp.identstars(1:end-1,:);
    
else
  
  SkMp.identstars = [];
  
end
