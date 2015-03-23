% SKMP_CLOSE - ending of the skymap session
%   
% 
% 


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

close(SkMp.figsky)
if isfield(SkMp,'figzoom')
  close(SkMp.figzoom)
end
if isfield(SkMp,'errorfig')
  close(SkMp.errorfig)
end
if isfield(SkMp,'fig_spec')
  close(SkMp.fig_spec)
end
clear OptF_struct SkMp optpar savename saveok starpar ...
    stars_pars thisstar


