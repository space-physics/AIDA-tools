% Move to where the overview-keogram files are stored. On snake
% this is at /alis/overviews/

% keep this directory
ALIS_overview_dir = pwd;

% List all overview-files
[overview_files,overview_files] = my_unix('ls -1 alis_overview[12][0-9]*.mat');
overview_files =overview_files(1:end-1,:);

% Parse out the corresponding dates.
overview_dates = [str2num(overview_files(:,14:17)),str2num(overview_files(:,18:19)),str2num(overview_files(:,20:21))];

% Time limits for 3 coarse figures a day (if there is any data for
% the time period)
t_lims1 = [0 7 14 24];
% ...and time limits for 1-hour-figures (if there is any data for
% that hour)
t_lims2 = 0:24;

% In case we turn into problems keep record of those dates, and
% just plug along with the next date
bad_dates = '';


for i_day = length(overview_dates):-1:1,
  
  % Make path name to file
  target_dir = num2str(overview_dates(i_day,:),'%02d/');
  % If we have allready made the images the directory should exist
  % and we dont have to do them again
  if ~exist(target_dir)
    % Else we have to start working
    mkdir(target_dir)
    disp(['Making directory: ',target_dir])
    % Load the keograms and other stuff
    load(overview_files(i_day,:))
    % Move to the directory of the day
    cd(target_dir)
    % Do things one time periof at a time
    for indx_t = 1:(length(t_lims1)-1),
      
      keo = {};
      t_obs = {};
      wl_emi = {};
      
      stn_no = [];
      stns = Stns;
      for i_stn = 1:length(Stns),
        i_t = find(( t_lims1(indx_t) <= T_obs{Stns(i_stn)} ) & ...
                   ( T_obs{Stns(i_stn)} <= t_lims1(indx_t+1)));
        if ~isempty(i_t)
          keo{Stns(i_stn)} = Keo{Stns(i_stn)}(:,i_t);
          t_obs{Stns(i_stn)} = T_obs{Stns(i_stn)}(i_t);
          wl_emi{Stns(i_stn)} = Wl_emi{Stns(i_stn)}(i_t);
        else
          stn_no = [stn_no,i_stn];
        end
      end
      if ~isempty(stn_no)
        stns(stn_no) = [];
      end
      if ~isempty(stns)
        try
          alis_overview_keos4web(overview_dates(i_day,:),t_lims1(indx_t+[0:1]),keo,t_obs,wl_emi,stns)
        catch
          bad_dates = str2mat(bad_dates,overview_files);
        end
      end
    end
    for indx_t = 1:(length(t_lims2)-1),
      
      keo = {};
      t_obs = {};
      wl_emi = {};
      
      stn_no = [];
      stns = Stns;
      for i_stn = 1:length(Stns),
        i_t = find(( t_lims2(indx_t) <= T_obs{Stns(i_stn)} ) & ...
                   ( T_obs{Stns(i_stn)} <= t_lims2(indx_t+1)));
        disp([overview_dates(i_day,:),t_lims2(indx_t+1),i_stn,length(i_t)])
        if ~isempty(i_t)
          keo{Stns(i_stn)} = Keo{Stns(i_stn)}(:,i_t);
          t_obs{Stns(i_stn)} = T_obs{Stns(i_stn)}(i_t);
          wl_emi{Stns(i_stn)} = Wl_emi{Stns(i_stn)}(i_t);
        else
          stn_no = [stn_no,i_stn];
        end
      end
      if ~isempty(stn_no)
        stns(stn_no) = [];
      end
      if ~isempty(stns)
        try
          alis_overview_keos4web(overview_dates(i_day,:),t_lims2(indx_t+[0:1]),keo,t_obs,wl_emi,stns)
        catch
          bad_dates = str2mat(bad_dates,overview_files);
        end
      end
    end
  else
    disp(['Directory: ',target_dir,' already exists, skipping'])
  end
  cd(ALIS_overview_dir)
  
end
