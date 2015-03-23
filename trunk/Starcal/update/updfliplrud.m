function SkMp = updfliplrud(SkMp)


%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

indx = get(SkMp.ui3(6),'value')-1;
if indx == 1 | indx == 2
  
  SkMp.optpar(indx) = -SkMp.optpar(indx);
  SkMp = updstrpl(SkMp);
  set(SkMp.ui3(6),'value',1)
  
end
