function [ph,SkMp] = plotspec(SkMp)
% SKMP-private called through skymap/starcal GUI and makes
% a plot of the Pulkovo spectra of a selected star - if it exists.



%   Copyright � 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


[SkMp,staraz,starze,starid,starmagn,thisstar] = updstrinfo(SkMp);

star_spec_dir = fullfile(fileparts(which('skymap')),'stars');
qwe_cmd = ['cd ',star_spec_dir,';./getsp ',num2str(thisstar.Bright_Star_Nr),' > /tmp/stasr12.qwe'];

try
  %TBR?: [qwe_q,qwe_w] = unix(qwe_cmd);  
  [qwe_q] = unix(qwe_cmd);
  if qwe_q == 0
    
    qwe_fp = fopen('/tmp/stasr12.qwe','r');
    qwe_i = 1;
    %keyboard
    while(~feof(qwe_fp))
      qwe_l = fgets(qwe_fp);
      if ~isempty(str2num(qwe_l))
        qwe_spe15(qwe_i,1:length(str2num(qwe_l))) = str2num(qwe_l);
        if length(str2num(qwe_l))==1
          qwe_spe15(qwe_i,2) = nan;
        end
        qwe_i = qwe_i+1;
      end
    end
    fclose(qwe_fp);
    %qwe_i
    if ~isfield(SkMp,'fig_spec')
      
      SkMp.fig_spec = figure;
      
    end
    
    figure(SkMp.fig_spec)
    %qwe2nan_indx = find(abs(diff(qwe_spe15))>300);
    %qwe_spe15(qwe2nan_indx,:) = nan;
    qwe_spe15(abs(diff(qwe_spe15))>300,:) = nan;
    PH = plot(qwe_spe15(:,1),qwe_spe15(:,2));
    xlabel('wavelength (nm)','fontsize',16)
    ylabel('Energy flux W/m^2/m','fontsize',16)
    title(['Spectra for ',thisstar.Name,', `bright star nr'': ',num2str(thisstar.Bright_Star_Nr)],'fontsize',16)
    
    unix('rm /tmp/stasr12.qwe');
    
    if nargout > 0
      ph = PH;
    end
  else
    
    disp('For this star there is no specra in `Pulkovo Spectrophotometric Catalog''')
    ph = [];
  end
  
catch
  
  warning('Only works in unix-like environments?')
  
end
