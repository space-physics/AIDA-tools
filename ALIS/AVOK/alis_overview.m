function [M,filters,Times,I_minmax] = alis_overview(files,POs,OPS)
% ALIS_OVERVIEW - Overviews of alis data, movie or image-mosaics
% 
% Calling:
% [M,filters,Times,I_minmax] = alis_overview(files,POs,OPS)
% 
% Input:
%   FILES - Cell array of image filenames {files_S1,files_S2,files_S0}
%   POS   - Cell array of PRE_PROC_OPS - see TYPICAL_PRE_PROC_OPS
%   OPS   - Options structure where the following optional fields
%   are used:
%   OPS.clear_fig = 0;              clear_fig = 0 leave previous images useful
%                                   when stepping through data with
%                                   one timestep per figure frame
%                                   whith hole in data-stream
%   OPS.subplots = [2 3];           two first argument to subplot calls
%   OPS.subplot_pos = [1 2 3 4 5 6];subplot ordering
%   OPS.rgb_or_pseudo = 'rgb';      [{'rgb'}| 'pseudo'] colour plotting mode
%   OPS.times_until_restart = 1;    number of timesteps to plot on the same figure
%   OPS.overview_sppos = 0;         Position of overviewplot, -1 disables, > 0
%                                   makes that subplotpos the designated subplotpos
%   OPS.out_arg = 0;                outarg-type 0: movie, 1:
%                                   currently displayed images
%   OPS.make_pause = 0;             Waiting before removing plots,
%                                   makes it possible to print save
%                                   figure manually
%   OPS.out_base_filename = '';     Base filename for automatic
%                                   printing of figures to file
%   OPS.printcmd = '';              Automatic print command, ex:
%                                   'print -dpsc2 -Pfiery2'
%   A structure with the default struct is returned when the
%   function is called without arguments

% Copyright Bjorn Gustavsson 20050112

global bx by

if nargin == 0
  
  M.clear_fig = 0;               % clear_fig = 0 leave previous images useful
                                 % when stepping through data with
                                 % one timestep per figure frame
                                 % whith hole in data-stream
  M.subplots = [2 3];            % two first argument to subplot calls
  M.subplot_pos = [1 2 3 4 5 6]; %  subplot ordering
  M.rgb_or_pseudo = 'rgb';       % rgb (or pseudo) colour plotting
  M.times_until_restart = 1;     % number of timesteps to plot on the same figure
  M.overview_sppos = 0;          % Position of overviewplot, -1 disables, > 0
                                 % makes that subplotpos the designated subplotpos
  M.out_arg = 0;                 % outarg-type 0: movie, 1:
                                 % currently displayed images
  M.make_pause = 0;              % Waiting before removing plots,
                                 % makes it possible to print save
                                 % figure manually
  M.out_base_filename = '';      % Base filename for automatic
                                 % printing of figures to file
  M.printcmd = '';               % Automatic print command, ex:
                                 % 'print -dpsc2 -Pfiery2'
  M.caxis    = 'auto';           % default is to use automatic
                                 % limits for the colour axis,
                                 % otherwise use [cmin cmax] in
                                 % either [2 x length(files)] or
                                 % [2 x length(files) x length(files{i})] 
  M.plot_style = 'imgsc';        % Type of plot to make. [{'imgsc'}|'map_proj']
  M.map_limits = [-100 2 100 -100 2 100];  % horisontal limits of
                                           % maping [xmin dx xmax ymin dy ymax]
  M.map_alt = 110;               % Altitude to map the image onto
  M.timelabel_pos = 'y';         % position of time label [{'y'}|'x'|'z'|'t'|'i']
  return
  
end

%  Default options
clear_fig = 0;               % CL_F = 0 leave previous images when hole in data-stream
subplots = [2 3];            % two first argument to subplot calls
subplot_pos = [1 2 3 4 5 6]; %  subplot ordering
rgb_or_pseudo = 'rgb';       % rgb (or pseudo) colour plotting
times_until_restart = 1;     % number of timesteps to plot on the same figure
overview_sppos = 0;          % Position of overviewplot, -1 disables, > 0
                             % makes that subplotpos the designated subplotpos
out_arg = 0;
make_pause = 0;
out_base_filename = '';
printcmd = '';
cax = 'auto';
plot_style = 'imgsc';
map_limits = [-100 2 100 -100 2 100];
map_alt = 110;
time_label_pos = 'y';

% Handle the user options
if nargin > 2

  if isfield(OPS,'clear_fig')
    clear_fig = OPS.clear_fig; % user suplied CL_F
  end
  if isfield(OPS,'subplots')
    subplots = OPS.subplots; % user supplied two first argument to subplot
  end
  if isfield(OPS,'subplot_pos')
    subplot_pos = OPS.subplot_pos; % user supplied subplot ordering
  end
  if isfield(OPS,'rgb_or_pseudo')
    rgb_or_pseudo = OPS.rgb_or_pseudo;
  end
  if isfield(OPS,'times_until_restart')
    times_until_restart = OPS.times_until_restart;
  end
  if isfield(OPS,'overview_sppos')
    overview_sppos = OPS.overview_sppos;
  end
  if isfield(OPS,'out_arg')
    out_arg = OPS.out_arg;
  end
  if isfield(OPS,'make_pause')
    make_pause = OPS.make_pause;
  end
  if isfield(OPS,'out_base_filename')
    out_base_filename = OPS.out_base_filename;
  end
  if isfield(OPS,'M.printcmd')
    printcmd = OPS.M.printcmd;
  end
  if isfield(OPS,'caxis')
    cax = OPS.caxis;
  end
  if isfield(OPS,'plot_style')
    plot_style = OPS.plot_style;
  end
  if strcmp(plot_style,'map_proj')
    map_limits = OPS.map_limits;
    map_alt = OPS.map_alt;
  end
  if isfield(OPS,'time_label_pos')
    time_label_pos = OPS.time_label_pos;
  end
end

do_print = 0;
if ~isempty(out_base_filename) | ~isempty(printcmd)
  do_print = 1;
end
if do_print & isempty(printcmd)
  printcmd = 'print -depsc2 -noui';
end

% Set the positions of hte alis stations
ap = [0   0  0
      64.14218725650279   -31.86799805059328  -0.4021440345184266
      53.13179754255706   21.58681354721001  -0.2578326940640405
      14.80937274138702   -56.36541170065802  -0.2662535704565858
      -65.07707331579783   57.72751986387349  -0.5932546375529117
      -58.9199195880307   2.001795856330272  -0.2724597759225365
      .5   3  0
      0 0 0
      0 0 0
      40 90 -.6
      -40 120 -.6
     ];


% Start with the first items in each group of FILES
file_indx = ones(size(files));

% First time allways start wihtout offset
plot_time_nr = 0;
tot_indx = 1;
frame_indx = 1;
% First time load an image from each of the Cells in FILES
plot_indx = 1:length(files);

while 1,
  
  for i = plot_indx,
    % Here read a new file from each filelist in FILES _that_ was
    % just displayed 
    if file_indx(i) <= size(files{i},1)
      [d{i},h,o{i}] = inimg(files{i}(file_indx(i),:),POs{i});
      [by,bx] = size(d{i});
      if nargout > 3
        I_minmax(tot_indx,i,2) = min(d{i}(:));
        I_minmax(tot_indx,i,1) = max(d{i}(:));
      end
      % Get the new times.
      times(i) = sum(o{i}.time(4:6).*[1 1/60 1/3600]);
      % If requested convert the image to RGB format
      if min(size(rgb_or_pseudo)) > 1
        this_rgb = deblank(rgb_or_pseudo(i,:));
      else
        this_rgb = rgb_or_pseudo;
      end
      if strcmp(this_rgb,'rgb')
        [d{i},clr] = alis_img2rgb(d{i},o{i}.filter);
        clrs(i,:) = clr;
      else
        clrs(i,:) = alis_emi2clrs(o{i}.filter);
      end
      if strcmp(plot_style,'map_proj')
        [X,Y] = meshgrid(map_limits(1):map_limits(2):map_limits(3),...
                         map_limits(4):map_limits(5):map_limits(6));
        Z = map_alt*ones(size(X));
        U = Z;
        V = Z;
        
        [U(:),V(:)] = project_point(ap(o{i}.station,:),...
                                    o{i}.optpar,...
                                    [X(:) Y(:) Z(:)]',[],[bx by]);
        D(:,:,3) = Z;
        D(:,:,3) = interp2(d{i}(:,:,3),U,V);
        D(:,:,2) = interp2(d{i}(:,:,2),U,V);
        D(:,:,1) = interp2(d{i}(:,:,1),U,V);
        d{i} = D;
      end
      % Set "vital" output
      filters(tot_indx,i) = o{i}.filter;
      Times(tot_indx,i) = times(i);
      % Set variables for alis_overviewplot
      stn(i) = o{i}.station;
      az(i) = o{i}.az;
      ze(i) = o{i}.ze;
    else
      % We are at the end of FILES{i} so no idea to read more files
      % there...
      times(i) = inf;
    end
    % Increment the indices for the FILES we read
    file_indx(i) = file_indx(i) + 1;
  end
  % Maybe shift this one furter down...
  if all(isinf(times))
    return
  end
  
  if clear_fig % then clear the figure every lap
    clf
  end
  if plot_time_nr == 0 % no mixing with older images so clear the
                       % fig when we start over at the beginning of
                       % the subplot-pannels
    clf
  end
  
  plot_pos_offset = plot_time_nr * subplots(2);
  
  % Out of all the currently stored data find the ones that are
  % taken at the earliest time.
  [stime,st_indx] = sort(times);
  plot_indx = st_indx(stime==stime(1));
  time_str = o{plot_indx(1)}.time;
  % And plot everything for those
  for i = plot_indx,
    
    % Get the correct subplot
    plot_pos = plot_pos_offset + subplot_pos(i);
    if ( plot_pos <= subplots(1)*subplots(2) )
      mysubplot(subplots(1),subplots(2),plot_pos)
    else
      % If we try to add more subplots than the figure can hold add
      % them outside and add scrollbar.
      scrollsubplot(subplots(1),subplots(2),plot_pos)
    end
    if strcmp(plot_style,'map_proj')
      thimgs = find(subplot_pos(plot_indx) == subplot_pos(i));
      %%% Haer ska vi in med plotstyle...
      % for alla med aktuellt subplot_pos skaka fram medelvaerdet
      % foer alla tre faergskikten och sen aer det vel bara att koera
      % tcolor
      % Enkelt att medelvaerda! alla ska ligga 0-1 bara att
      % normalisera om igen!
      %% inte saa enkelt problem med nan!
      ii = 1;
      clear r g b
      for j = plot_indx(thimgs),
        r(:,:,ii) = d{j}(:,:,1);
        g(:,:,ii) = d{j}(:,:,2);
        b(:,:,ii) = d{j}(:,:,3);
        ii = ii +1;
      end
      r = my_nanmean(r,3);
      g = my_nanmean(g,3);
      b = my_nanmean(b,3);
      tsurf(X,Y,Z,cat(3,r,g,b))
      if ~isstruct(o{i}.optpar)
        text(-50,-50,sprintf('%02.3g, %02.3g, %02.3g,',o{i}.optpar(3:5)),'color','w')
      elseif isfield(o{i}.optpar,'rot')
        text(-50,-50,sprintf('%02.3g, %02.3g, %02.3g,',o{i}.optpar.rot),'color','w')
      else
        text(-50,-50,sprintf('%02.3g, %02.3g, %02.3g,',[0,0,0]),'color','w')
      end
    else
      imagesc(d{i}),axis xy
    end
    if time_label_pos == 'i'
      text(10,10,sprintf('%02d-%02d:%02d:%02d',o{i}.time(3:6)),'color','w')
    end
    if length(size(cax)) == 3
      caxis(squeeze(cax(:,i,tot_indx)))
    elseif all(size(cax) == [2 length(files)])
      caxis(squeeze(cax(:,i,tot_indx)))
    else
      caxis(cax)
    end
    
    set(gca,'xtick',[],'ytick',[])
    if plot_time_nr == 0
      thndl = title(['S',num2str(o{i}.station,'%02d')]);
      if subplots(1) < 4
        set(thndl,'fontsize',18)
      elseif subplots(1) < 6
        set(thndl,'fontsize',16)
      elseif subplots(1) < 7
        set(thndl,'fontsize',14)
      elseif subplots(1) < 8
        set(thndl,'fontsize',12)
      elseif subplots(1) < 10
        set(thndl,'fontsize',10)
      end
    end
  end
  if overview_sppos == 0
    % Default position of the overviewplot
    curr_ax = axes('position',[0.01 0.5-.075 .15 .15]);
    alis_overviewplot(stn(plot_indx),az(plot_indx),ze(plot_indx),clrs(plot_indx,:),time_str)
  elseif overview_sppos > 0
    % Or in a real subplot of its own...
    plot_pos = plot_pos_offset + overview_sppos;
    if ( plot_pos <= subplots(1)*subplots(2) )
      mysubplot(subplots(1),subplots(2),plot_pos)
    else
      scrollsubplot(subplots(1),subplots(2),plot_pos)
    end
    alis_overviewplot(stn(plot_indx),az(plot_indx),ze(plot_indx),clrs(plot_indx,:),time_str)
  end
  
  if plot_time_nr == times_until_restart-1
    
    if make_pause
      disp('push any key to continue')
      pause
    end
    if ~isempty(out_base_filename)
      f_name = [out_base_filename,num2str(tot_indx,'%04d'),'.eps'];
    end
    if do_print
      try
        eval([printcmd,' ',f_name])
      catch
        disp(['WARNING! Could not write file: ',f_name])
      end
    end
  end
  
  
  if out_arg == 0 && plot_time_nr+1 == times_until_restart
    M(frame_indx) = getframe(gcf);
    frame_indx = frame_indx + 1;
  elseif out_arg == 1
    M = d{plot_indx};
  end
  tot_indx = tot_indx + 1;
  
  plot_time_nr = rem(plot_time_nr+1,times_until_restart);
  
end
