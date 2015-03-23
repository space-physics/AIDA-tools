function saveok = saveacc(SkMp)
% SAVEACC - save optical parameters as ACC-file
%   
% Calling:
% save_ok = saveacc(SkMp)


%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Calling sequence...
% savename = ['S0',num2str(SkMp.obs.station),'_',SkMp.obs.filename,'.acc'];
savename = genfilename(SkMp, 1);

try
  saveok = saveas_acc(SkMp.optpar, ...
                      SkMp.obs.time, ...
                      savename, ...
                      SkMp.obs.station, ...
                      SkMp.obs.az, ...
                      SkMp.obs.ze, ...
                      SkMp.optmod);
catch
  saveok = -1;
  disp(['Could not perform saveas_acc for file: ',savename])
end

% TODO: 
% Make the function also save optical parameters in
% $(aida-home)/.data/optic-cals or something similar.
%############################
% DONE!
%############################
% If there is a
% calibration file already, make a new one with higher version
% name. Also come up with some way to weight the different variants
% according to number of stars and total error or the like.
