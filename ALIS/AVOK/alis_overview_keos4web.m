function avok = alis_overview_keos4web(date,t_lims,Keo,T_obs,Wl_emi,Stns)
% ALIS_OVERVIEW_KEOS4WEB - image ALIS overview keograms
% Produces png files for use as web-interface.
%
% Calling:
%  AvOk = alis_overview_keos4web(date,Keo,T_obs,Wl_emi,Stns)
%

% Copyright B. Gustavsson 20050805


STNN2NAME = {'Kiruna','Merasjarvi','Silkimuotka','Tjautjas', ...
             'Abisko','Nikkaluokta','Knutstorp','8','Optiklab','Bus'};

pause_time = 1;
clf

% number of unique stations making observations
nrstns = unique(Stns);
% in UFNR wavelengths
ufnr = unique([Wl_emi{:}]);

% To store number of exposures from each station at each wavelength
to_day_overview = zeros(length(ufnr),length(nrstns));
% Redundant?
empty_axis = zeros(length(nrstns),length(ufnr));

% For each station
for j = 1:length(nrstns),
  
  % Take "its" total keogram...
  keo = Keo{Stns(j)};
  % ...and remove nan&inf...
  keo(~isfinite(keo(:))) = 0;
  % and take the corresponding filter array
  wl_emi = Wl_emi{Stns(j)};
  % and observation times.
  t_obs = T_obs{Stns(j)};
  % Loop over all unique filters.
  for i = 1:length(ufnr),
    % create axis
    subplot(length(ufnr),length(nrstns),j+length(nrstns)*(i-1))
    % If the current station have made any observations in the
    % current filter
    if any(wl_emi==ufnr(i))
      % ...then count the number of exposures...
      to_day_overview(i,j) = sum(wl_emi==ufnr(i));
      % ...and most importandlty display it.
      if sum(wl_emi==ufnr(i))>1
        pcolor(t_obs(wl_emi==ufnr(i)),1:size(keo,1),keo(:,wl_emi==ufnr(i)))
      else
        imagesc(t_obs(wl_emi==ufnr(i)),1:size(keo,1),keo(:,wl_emi==ufnr(i)))
      end
      shading flat,
      % try to cut off the \pm peaks from the intensity scale
      try
        imgs_smart_caxis(0.01,keo(:,wl_emi==ufnr(i)));
      end
    end
    % Set the axis to the time limits and 1-128 that are the
    % uniform size of the keogram
    axis([t_lims 1 128])
    % Since we dont keep track of what the keogram-column
    % coordinate represents just put the ticklabels away
    set(gca,'yticklabel','')
    if j == 1
      % Set the y-label in the first column to the emission
      ylh(i) = ylabel(num2str(ufnr(i)),'fontsize',16);
    end
    if i == 1
      % Set the title in the first row to the station name
      tlh(j) = title(STNN2NAME{Stns(j)},'fontsize',16);
    end
    if i == length(ufnr)
      % Set the xlabel in the last row to:
      xlh(j) = xlabel('time (UT)');
    end
    if to_day_overview(i,j) == 0
      % If the axis is empty hide it
      axis off
    end
    
  end
  
end
% Make sure the labels are visible even if the axis are hidden
set(xlh,'visible','on')
set(ylh,'visible','on')
set(tlh,'visible','on')
% $$$ to_day_overview

% Here we remove all xticklabels except the bottommost one that
% belongs to an axis with data.
for j = 1:length(nrstns),
  
  wl_emi = Wl_emi{(j)};
  i = length(ufnr);
  keep_this_xtl = 1;
  while i > 0 && to_day_overview(i,j) == 0
    subplot(length(ufnr),length(nrstns),j+length(nrstns)*(i-1))
    set(gca,'xticklabel','')
    i = i-1;
  end
  i = i-1;
  while i > 0
    subplot(length(ufnr),length(nrstns),j+length(nrstns)*(i-1))
    set(gca,'xticklabel','')
    i = i-1;
  end
  
end

% only if there is _some_ data print an image with name in this
% pattern: yyyymmddThh_0-hh_1.png
if sum(to_day_overview(:)) > 0
  print('-dpng',[num2str(date,'%02d'),'T',num2str(t_lims,'%02d-%02d'),'.png'])
end
