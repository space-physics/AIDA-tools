function guigetspec(SkMp)
% "Private" script (!) called through skymap/starcal GUI and asks
% for a variable name to export the Pulkovo spectra of a selected
% star to - if it exists.


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

[SkMp,staraz,starze,starid,starmagn,thisstar] = updstrinfo(SkMp);
% snitsa till pathen till getsp

star_spec_dir = fullfile(fileparts(which('skymap')),'stars');
qWe_cmd = ['cd ',star_spec_dir,';./getsp ',num2str(thisstar.Bright_Star_Nr),' > /tmp/stasr12.qwe'];

%TBR?: [qWe_q,qWe_w] = unix(qWe_cmd);
[qWe_q] = unix(qWe_cmd);
if qWe_q == 0
  
  qWe_fp = fopen('/tmp/stasr12.qwe','r');
  qWe_i = 1;
  while(~feof(qWe_fp))
    qWe_l = fgets(qWe_fp);
    if ~isempty(str2num(qWe_l)) 
      qWe_spe15(qWe_i,:) = str2num(qWe_l);
      qWe_i = qWe_i+1;
    end
  end
  
  qWe_varname = in_def2('Variable name for storing spectra','Str_spec');
  assignin('base',qWe_varname,qWe_spe15)
  %qWe_ass_str = [qWe_varname,' = qWe_spe15;'];
  %eval(qWe_ass_str)
  
  unix('rm /tmp/stasr12.qwe');
  
else
  
  disp(['No specra in `Pulkovo Spectrophotometric Catalog'' for star: ',num2str(thisstar,'%d')])
  
end
