function avok = alis_img_overview_keos(date)
% ALIS_VIEW_OVERVIEW_KEOS - view ALIS overview keograms
% Starts the GUI for viewing ALIS overview keograms
%
% Calling:
%  AvOk = alis_view_overview_keos(date)
%

% Copyright B. Gustavsson 20050805

global AvOk
evalin('base','global AvOk')% UGGGLY
load alis_overviews_dir.mat % file with path to all the alis_overview-files

% Check if we need to create AvOk
if isempty(AvOk)
  AvOk.create = 1;
end

if ~isfield(AvOk,'data_inputdir')
  AvOk.data_inputdir = uigetdir('', 'Select a directory with OverViewKeograms');
  if AvOk.data_inputdir == 0
    AvOk.data_inputdir = alis_overviews_dir;
  end
end
if ~isfield(AvOk,'data_outdir')
  AvOk.data_outdir = uigetdir('', 'Select a directory for saving results');
  if AvOk.data_outdir == 0
    AvOk.data_outdir = pwd;
  end
end

AvOk.STNN2NAME = {'Kiruna','Merasjarvi','Silkimuotka','Tjautjas', ...
                  'Abisko','Nikkaluokta','Knutstorp','8','Optiklab','Bus'};



% make a list of all alis_overview-files.
[q,w] = my_unix(['find ',AvOk.data_inputdir,' -name \*[0-9]\*.mat']);
AvOk.overview_files = w(1:end-1,:);
dates = datenum(str2num(AvOk.overview_files(:,end-11:end-8)),...
                str2num(AvOk.overview_files(:,end-7:end-6)),...
                str2num(AvOk.overview_files(:,end-5:end-4)));
[dates,sortindx] = sort(dates);
AvOk.overview_files = AvOk.overview_files(sortindx,:);

if date == -1              % step back to previous day with data.
  AvOk.date_indx = AvOk.date_indx-1;
elseif date == 1           % step forward to next day with data
  AvOk.date_indx = AvOk.date_indx+1;
else                       % Find the closest day to date.
  [mindiff,date_indx] = min(abs(repmat(datenum(date),[size(dates,1) 1])-dates));
  AvOk.date_indx = date_indx;
end
% choose the closest date
if AvOk.date_indx == 0
  
  AvOk.date_indx = 1;
  disp('Alis_view_overview_keos: already at first day with data')
  
elseif  AvOk.date_indx > size(AvOk.overview_files,1)
  
  disp('Alis_view_overview_keos: already at latest day with data')
  AvOk.date_indx = AvOk.date_indx - 1;
  
end
AvOk.date = datevec(dates(AvOk.date_indx));

if AvOk.create
  
  AvOk = avok_create(AvOk);
  AvOk.create = 0;
  AvOk = avok_update(AvOk,AvOk.date);
  
else
  AvOk = avok_update(AvOk,AvOk.date);
end

load(['alis_overview',num2str([AvOk.date(1:3)],'%02d')])

AvOk.Keo = Keo;
AvOk.Files = Filenames;
AvOk.Wl_emi = Wl_emi;
AvOk.Optps = Optps;
AvOk.T_obs = T_obs;
AvOk.Stns = Stns;


nrstns = unique(AvOk.Stns);% Verkar vara buggigt jaemfoert med vad
                           % som kommit in i overviewfilerna.

ufnr = unique([Wl_emi{:}]);

figure(AvOk.fig_keo)

t_all = [];
for j = 1:length(nrstns),
  
  keo = Keo{AvOk.Stns(j)};
  % remove nan&inf...
  keo(~isfinite(keo(:))) = 0;
  wl_emi = Wl_emi{AvOk.Stns(j)};
  t_obs = T_obs{AvOk.Stns(j)};
  t_all = [t_all t_obs'];
  optps = Optps{AvOk.Stns(j)};
  filenames = Filenames{AvOk.Stns(j)};
  
  for i = 1:length(ufnr),
    
    subplot(length(ufnr),length(nrstns),j+length(nrstns)*(i-1))
    if any(wl_emi==ufnr(i))
      
      if sum(wl_emi==ufnr(i))>1
        if prod(size(keo(:,wl_emi==ufnr(i)))) > 800
          pcolor(t_obs(wl_emi==ufnr(i)),1:size(keo,1),img_histeq(keo(:,wl_emi==ufnr(i)),200))
        else
          pcolor(t_obs(wl_emi==ufnr(i)),1:size(keo,1),keo(:,wl_emi==ufnr(i)))
        end
      else
        if prod(size(keo(:,wl_emi==ufnr(i)))) > 800
          imagesc(t_obs(wl_emi==ufnr(i)),1:size(keo,1),img_histeq(keo(:,wl_emi==ufnr(i)),200))
        else
          imagesc(t_obs(wl_emi==ufnr(i)),1:size(keo,1),keo(:,wl_emi==ufnr(i)))
        end
      end
      shading flat,
      ax(i,j,:) = axis;
      
    end
    if j == 1
      ylabel(num2str(ufnr(i))),
    end
    if i == 1
      title(AvOk.STNN2NAME{AvOk.Stns(j)},'fontsize',16),
    end
    %keyboard
  end
end

AvOk.all_tobs = unique(t_all);
ax1 = min(min(ax(:,:,1)));
ax2 = max(max(ax(:,:,2)));

AvOk.subplots = [length(ufnr),length(nrstns)];
AvOk.subppos = 1:prod(AvOk.subplots);
for j = 1:length(nrstns),
  
  wl_emi = Wl_emi{AvOk.Stns(j)};
  for i = 1:length(ufnr),
    
    if diff(squeeze(ax(i,j,3:4))) == 0
      ax(i,j,3:4) = [1 128];
    end
    subplot(length(ufnr),length(nrstns),j+length(nrstns)*(i-1))
    axis([ax1 ax2 ax(i,j,3) ax(i,j,4)])
    timetick
    set(gca,'yticklabel','')
    if (i < length(ufnr))
      set(gca,'xticklabel','')
    else
      xlabel('time (UT)')
    end
    
  end
  
end
set(gcf,'name',['Overview keograms from: ',sprintf('%02d-%02d-%02d',AvOk.date(1:3))])
AvOk.ax0 = axis;

avok = AvOk;


set(gcf,'windowbuttondownfcn','AvOk = alis_zoom_or_auto_overview(AvOk,[]);');



function avok = avok_update(avok,date)
% avok = avok_update(avok,date)
%
% AVOK_UPDATE - update alis-view-overview-keograms user interface
%   

today = avok.date;

avok.tomorrow = datevec(datenum(today)+1);
avok.yesterday = datevec(datenum(today)-1);
avok.netxmonth = datevec(datenum([today(1:2)+[0, 1], 1]));
avok.lastmonth = datevec(datenum([today(1:2)+[0, -1], 1]));
avok.netxyear = datevec(datenum([today(1)+1, 1, 1]));
avok.lastyear = datevec(datenum([today(1)-1, 1, 1]));
