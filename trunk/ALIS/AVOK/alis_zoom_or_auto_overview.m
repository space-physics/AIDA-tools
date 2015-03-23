function AvOk = alis_zoom_or_auto_overview(AvOk,t_y)
% ALIS_ZOOM_OR_AUTO_OVERVIEW - GUI-fcn for ALIS keogram overviewing
% 
persistent time_0 indx_offset

if isempty(t_y)
  
  %gca
  pnt = get(gcf,'currentpoint');
  xy1 = get(gca,'currentpoint');
  rbbox([pnt 0 0],pnt)
  xy2 = get(gca,'currentpoint');
  selection_type = get(gcf,'selectiontype');
  
  if all(xy1==xy2)
    ax0 = axis;
    % only zoom in x
    dx = ax0(2)-ax0(1);
    xmin = max(ax0(1),xy1(1)-dx/4);
    xmax = max(ax0(2),xy1(1)+dx/4);
    zoom2ax = [xmin xmax ax0(3:4)];
  else
    %%% zoom to selected rectangle
    zoom2ax = [sort([xy1(1,1) xy2(1,1)]) sort([xy1(1,2) xy2(1,2)])];
  end
  
  switch selection_type
   case 'normal'
    subppos = AvOk.subppos;
    subplots = AvOk.subplots;
    for i = 1:length(subppos)
      subplot(subplots(1),subplots(2),subppos(i))
      axis(zoom2ax)
      timetick
    end
    return
   case 'alt'
    return
   case 'extend'
    subppos = AvOk.subppos;
    subplots = AvOk.subplots;
    for i = 1:length(subppos)
      subplot(subplots(1),subplots(2),subppos(i))
      axis(AvOk.ax0)
      timetick
    end
    return
   otherwise %%% open (doubleclick in linux)
    t_y = xy1; % get time to open images for.
  end
  
end
if isfield(AvOk,'fig_overview')
  set(AvOk.fig_overview,'pointer','watch')
end
set(AvOk.fig_keo,'pointer','watch')

if length(t_y) > 1
  indx_offset = 0;
  time_0 = t_y(1);
else
  indx_offset = t_y;  % just \pm 1 offset
end
%% Fix of timeshift to really small timestep
time_0 = time_0;
[time_u0,indx_u0] = min(abs(AvOk.all_tobs-time_0));
time_0 = AvOk.all_tobs(min(max(indx_u0+indx_offset,1),length(AvOk.all_tobs)));

PO = typical_pre_proc_ops;
PO.interference_level = 2.5;
PO.fix_missalign = 0;

% haer boer det spara lite...
load(['alis_overview',sprintf('%02d',[AvOk.date(1:3)])])

Stns = Stns;

nrstns = unique(Stns);
ufnr = unique([Wl_emi{:}]);


if isfield(AvOk,'these_files')
  AvOk = rmfield(AvOk,'these_files');
end

for j = 1:length(nrstns),
  
  wl_emi = Wl_emi{Stns(j)};
  filenames = Filenames{Stns(j)};
  t_obs = T_obs{Stns(j)};
  POs{j} = PO;
  
  fname = '';
  fnindx = 1;
  for i = 1:length(ufnr),
    
    if any(wl_emi==ufnr(i))
      
      tt = t_obs(wl_emi==ufnr(i));
      fnms = filenames(wl_emi==ufnr(i),:);
      [tmin,indx_tmin] = min(abs(tt-time_0));
      if tmin<60/3600
        time_best(fnindx) = tt(min(max(indx_tmin,1),size(fnms,1)));
        fname(fnindx,:) = fnms(min(max(indx_tmin,1),size(fnms,1)),:);
        fnindx = fnindx + 1;
      end
      
    end
    
  end
  if all(size(fname))
    [q,sort_on_time] = sort(time_best);
    Fnames{j} = fname(sort_on_time,:);
    Avok.these_files{j} = Fnames{j};
  end
  
end
  

try
  keep_indx = [];
  for i = 1:length(Fnames)
    if all(size(Fnames{i}))
      keep_indx = [keep_indx i];
    end
  end
  
  Fnames = Fnames(keep_indx);
  
  if ~isfield(AvOk,'fig_overview')
    
    AvOk = make_fig_overview(AvOk);
    ovOPS =                   alis_overview;
    ovOPS.subplots =          [length(ufnr) length(nrstns)+1];
    ovOPS.subplot_pos =        1+[1:length(nrstns)];
    ovOPS.overview_sppos =     1;
    ovOPS.rgb_or_pseudo =      'pseudo';
    ovOPS.times_until_restart = 500;
    AvOk.ovOPS = ovOPS;
    
  end
  
  figure(AvOk.fig_overview)
  clf
  alis_overview(Fnames,POs,AvOk.ovOPS);
  
  for i = 1:length(Fnames)
    disp(Fnames{i})
  end
catch
  disp(lasterr)
end

set(AvOk.fig_overview,'pointer','arrow')
set(AvOk.fig_keo,'pointer','crosshair')

function avok = make_fig_overview(avok)
% MAKE_FIG_OVERVIEW - 
%   

avok.fig_overview = figure;
drawnow

avok.nextim = uicontrol('Units','normalized',...
                        'Style','pushbutton',...
                        'Position',[.16,.0,.05,.03],...
                        'string','>',...
                        'Callback','AvOk = alis_zoom_or_auto_overview(AvOk,1);');
avok.previm = uicontrol('Units','normalized',...
                        'Style','pushbutton',...
                        'Position',[.11,.0,.05,.03],...
                        'string','<',...
                        'Callback','AvOk = alis_zoom_or_auto_overview(AvOk,-1);');
avok.next_im = uicontrol('Units','normalized',...
                         'Style','pushbutton',...
                         'Position',[.21,.0,.05,.03],...
                         'string','>>',...
                         'Callback','AvOk = alis_zoom_or_auto_overview(AvOk,10);');
avok.prev_im = uicontrol('Units','normalized',...
                         'Style','pushbutton',...
                         'Position',[.06,.0,.05,.03],...
                         'string','<<',...
                         'Callback','AvOk = alis_zoom_or_auto_overview(AvOk,-10);');
% $$$ avok.triang_im = uicontrol('Units','normalized',...
% $$$                           'Style','pushbutton',...
% $$$                           'Position',[.96,.0,.05,.03],...
% $$$                           'string','\Delta',...
% $$$                           'Callback','AvOk = alis_2_triang(AvOk);');

set(avok.nextim,'HandleVisibility','callback')%hidegui(avok.exportvars)
set(avok.previm,'HandleVisibility','callback')%hidegui(avok.exportvars)
set(avok.next_im,'HandleVisibility','callback')%hidegui(avok.exportvars)
set(avok.prev_im,'HandleVisibility','callback')%hidegui(avok.exportvars)
%hidegui(avok.nextim)
%hidegui(avok.previm)
%hidegui(avok.next_im)
%hidegui(avok.prev_im)

function tstr = t2s(time)
% T2S - convert time [hh.fractionhour] to 'hh:mm:ss'
%   


tstr = datestr(datenum([0 0 1 time 0 0]),13);
