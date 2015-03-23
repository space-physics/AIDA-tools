function err = spc_save_stars(PO, OPTS, IDENTSTARS, STARPARS, filtnr, Stime, files,saveFileName)
% SPC_SAVE_STARS - save scanned star data for spec cal scripts
%  Good to use after SPC_SCAN_FOR_STARS to avoid loosing time-consuming work!
%
% SYNOPSIS
%   err = spc_save_stars(PO, OPTS, IDENTSTARS, STARPARS, filtnr, Stime,files, SaveFileName)
% 

% Copyright M V

err = 0;

try
  
  save(saveFileName, 'PO', 'OPTS', 'IDENTSTARS', 'STARPARS', 'filtnr', 'Stime', 'files');
  
catch
  err = 1;
end
