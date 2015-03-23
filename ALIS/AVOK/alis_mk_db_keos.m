function ok = alis_mk_db_keos()
% ALIS_MK_DB_KEOS - Update ALIS Keogram-database
%   
% Calling:
% ok = alis_mk_db_keos;
% Currently working under the assumption that the images are under
% /alis/stdnames and in a directory tree with the following
% structure:
% /alis/stdnames/YEAR/MONTH/DAY/
% From the DAY directory files for all images taken that day is
% searched for with unix FIND.


ok = 0;

Keo = [];
Wl_emi = [];
T_obs = [];
Optps = [];
Filenames = '';
Stns = [];

% Scan through these two trees
ALIS_data_dirs = {'/alis/stdnames'};

% This is the (two mutually exclusive) data-naming-sets
% Hopefully without quicklooks.
stn_keys = {'*0K.fits','*0M.fits','*0S.fits','*0T.fits','*0A.fits','*0N.fits','*0O.fits','*0B.fits'};
% For putting the output into their corresponding place
keys2stnnr = [7            2         3           4         5          6          1         10];

PO = typical_pre_proc_ops;
PO.find_optpar = 1;
PO.interference_level = 2.5;
PO.outimgsize = [128 128];
PO.fix_missalign = 0;
PO.verb = -2;
Stns = [];

for i1 = length(ALIS_data_dirs):-1:1,
  
  % Go to the root directory
  cd(ALIS_data_dirs{i1})
  % get the years that are archived there
  data_years = dir;
  data_years = data_years([data_years(:).isdir]);
  data_years = data_years(3:end); % first 2 will always(?) be ./ & ../
  
  for i2 = length(data_years):-1:1,
    
    % Go to the year directory
    cd(data_years(i2).name)
    % get the months that are archived there
    data_month = dir;
    data_month = data_month([data_month(:).isdir]);
    data_month = data_month(3:end);
        
    for i3 = length(data_month):-1:1,
      
      % Go to the month directory
      cd(data_month(i3).name)
      % get the days that are archived there
      data_days = dir;
      data_days = data_days([data_days(:).isdir]);
      data_days = data_days(3:end);
      
      for i4 = length(data_days):-1:1,
              
        % Go to the day directory
        todaystr = [data_years(i2).name,data_month(i3).name,data_days(i4).name];
        savefile = ['/alis/overviews/alis_overview',todaystr,'.mat'];
        if ~exist(savefile)
          cd(data_days(i4).name)
          for i5 = 1:length(stn_keys),
            
            % Find all images
            findfits_str = ['find ',pwd,' -name ',stn_keys{i5}];
            [q,w] = my_unix(findfits_str);
            if length(w)
              filenames = w(1:end-1,:);
              % for testing purposes
              %filenames = filenames(1:min(25,size(filenames,1)),:);
              disp(filenames([1 end],:))
              
              [d,h,o] = inimg(filenames(1,:),PO);  % this assumes
              if isfield(PO,'BE')               % that we have
                PO = rmfield(PO,'BE');          % le or BE for
              end                               % the whole   
              if isfield(PO,'LE')               % day for one 
                PO = rmfield(PO,'LE');          % station
              end
              if isfield(o,'le_or_be')
                PO = setfield(PO,o.le_or_be,1);
              end
              [keo,wl_emi,t_obs,optps,fnames] = alis_imgs2keos(filenames,PO);
              Keo{keys2stnnr(i5)} = keo;
              Wl_emi{keys2stnnr(i5)} = wl_emi;
              T_obs{keys2stnnr(i5)} = t_obs;
              Optps{keys2stnnr(i5)} = optps;
              Filenames{keys2stnnr(i5)} = fnames;
              Stns(end+1) = keys2stnnr(i5);
              todaystr = [data_years(i2).name,data_month(i3).name,data_days(i4).name];
              savestr = ['save /alis/overviews/alis_overview',todaystr,' Keo Wl_emi T_obs Filenames Optps Stns'];
              eval(savestr)
            end
          end
          % clearing the variables 
          Keo(:) = [];
          Wl_emi(:) = [];
          T_obs(:) = [];
          Optps(:) = [];
          Filenames(:) = '';
          Stns(:) = [];
          
          % and back up to the month directory
          cd('../')
        else
          disp(['Skipping: ',todaystr])
        end
      end
      cd('../')
    end
    cd('../')
  end
  cd('../')
end
ok = 1;
