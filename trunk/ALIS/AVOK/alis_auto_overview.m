function AvOk = alis_auto_overview(AvOk,t_y)
% ALIS_AUTO_OVERVIEW - function for displaying overview data
% keograms 

persistent time_0 indx_offset

if length(t_y) > 1
  indx_offset = 0;
  time_0 = t_y(1)
else
  indx_offset = indx_offset + t_y;
end

PO = typical_pre_proc_ops;
PO.interference_level = 2.5;
PO.fix_missalign = 0;

load(['alis_overview',num2str([AvOk.date(1:3)],'%02d')])

nrstns = unique(Stns);
ufnr = unique([Wl_emi{:}]);

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
      if tmin<1/60
        time_best(fnindx) = tt(min(max(indx_tmin+indx_offset,1),size(fnms,1)));
        fname(fnindx,:) = fnms(min(max(indx_tmin+indx_offset,1),size(fnms,1)),:);
        fnindx = fnindx + 1;
        disp('---------------------')
        disp(['Stns: ',num2str(Stns(j))])
        disp(['wl = ',num2str(ufnr(i)),[', [t0,t_best,dt] = ' ...
                            ''],num2str([time_0,time_best,tmin])])
        disp([tt(indx_tmin+indx_offset+[-1:1])])
        disp(fnms(min(max(indx_tmin+indx_offset,1),size(fnms,1)),:))
        
      end
      
    end
    
  end
  if all(size(fname))
    [q,sort_on_time] = sort(time_best);
    Fnames{j} = fname(sort_on_time,:);
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
  disp('nothing there?')
end

function avok = make_fig_overview(avok)
% MAKE_FIG_OVERVIEW - 
%   

avok.fig_overview = figure;

avok.nextim = uicontrol('Units','normalized',...
                        'Style','pushbutton',...
                        'Position',[.16,.0,.05,.05],...
                        'string','>',...
                        'Callback','AvOk = alis_auto_overview(AvOk,1)');
avok.previm = uicontrol('Units','normalized',...
                        'Style','pushbutton',...
                        'Position',[.11,.0,.05,.05],...
                        'string','<',...
                        'Callback','AvOk = alis_auto_overview(AvOk,-1)');

hidegui(avok.nextim)
hidegui(avok.previm)
