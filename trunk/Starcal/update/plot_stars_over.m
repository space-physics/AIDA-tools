% Callback wrapping script

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


hold on
plot(SkMp.identstars(:,3),SkMp.identstars(:,4), '.',...
     'color',SkMp.prefs.cl_st_pt,...
     'markersize',SkMp.prefs.sz_st_pt)
hold off
zoom on
