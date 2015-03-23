function err = saveoptident(SkMp)
% SAVEOPTIDENT - writes preliminary optical parameters and identified stars
% to STNyymmdd_hhmmss_param.mat
%
% SYNOPSIS
% 		err = saveoptindent(SkMp)
%
% to make sure loading is safe, data will be stored in variables
% SkMp.optpar -> optpar_saved
% SkMp.optmod -> optmod_saved
% SkMp.identstars -> identstars_saved
%
% returns 0 on successful run
%
%savefile = [SkMp.obs.filename(1:16),'_param.mat'];

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

savefile = genfilename(SkMp, 2);
fprintf('\nSaving %s...\n', savefile);
err = 0;
try
  optpar_saved = SkMp.optpar;
  optmod_saved = SkMp.optmod;
  identstars_saved = SkMp.identstars;
  % do not overwrite old files, instead keep them renamed as file.mat.001 file.mat.002 osv
  if exist(savefile,'file')
    sprintf('\nBacking up the old file as...');
    counter = '001';
    while exist([savefile, '.', counter],'file')
      counter = num2str(sprintf('%03d', str2num(counter)+1));
    end
    sprintf('%s', [savefile, '.', counter]);
    [status, message] = movefile(savefile, [savefile, '.', counter]);
  end
  save(savefile, 'optpar_saved', 'optmod_saved', 'identstars_saved');
catch
  err = -1;
  sprintf('\nWriting %s failed:\n%d:%s\n', savefile, status, message);
end
