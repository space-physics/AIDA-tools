function Filenames = alis_find_data2b(STNs,date,start_time,stop_time,ALIS_data_dir)
% ALIS_FIND_DATA - search for ALIS data from station STN at DATE
% taken between START_TIME and STOP_TIME. Function returns
% FILENAMES a cell array with full filenames to the images.
% 
% Current BUG/FEATURE - assumes that the ALIS data are located
% under: /home/DATA/ALIS/stdnames. Edit to set to the appropriate
% location. 
% 
% Example:
%   STN = 'BS';
%   Date = [1999 02 16];
%   Start_t = [1999 02 16 16 25 0];
%   Stop_t = [1999 02 16 18 25 0];
%   Files_Silki = alis_find_data(STN,Date,start_t,stop_t);
%
% TODO - clean up this bastard!


%   Copyright © 2007 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Scan through this tree
defALIS_data_dir = '/home/DATA/ALIS/stdnames';
if nargin < 5 | isempty(ALIS_data_dir)
  ALIS_data_dir = defALIS_data_dir;
end

% This is the data-naming-set
stn_keys = {'*0K.fits','*0M.fits','*0S.fits','*0T.fits','*0A.fits','*0N.fits','*0O.fits','*0B.fits'};
% For putting the output into their corresponding place
keys2stnnr = [7            2         3           4         5          6          1         10];

m_d = [31 28 31 30 31 30 31 31 30 31 30 31];
m_n = [ 1  2  3  4  5  6  7  8  9 10 11 12];

years  = date(1);%start_time(1):stop_time(1);
months = date(2);%start_time(2):stop_time(2);
days   = date(3);%start_time(3):stop_time(3);
hours  = start_time(4):stop_time(4);


% Start climbing the directory tree with ALIS data.
cd(ALIS_data_dir)
Filenames = {};

for i_s = 1:length(STNs)
  
  STN = STNs(i_s);
  filenames = {};
  for i_y = years,
    
    y_str = num2str(i_y,'%02d');
    try
      cd(y_str)
      for i_m = months,
        
        m_str = num2str(i_m,'%02d');
        try
          cd(m_str)
          for i_d = days,
            
            d_str = num2str(i_d,'%02d');
            try
              cd(d_str)
              for i_h = hours,
                h_str = num2str(i_h,'%02d');
                try
                  cd(h_str)
                  
                  files = dir(['*',STN,'.fits']);
                  [i_n,i_n] = sort({files.name});
                  files = files(i_n);
                  i_found = 1;
                  t_start = utc2sidt(start_time(1:3),start_time(4:end));
                  t_stop = utc2sidt(stop_time(1:3),stop_time(4:end));
                  t_file = sscanf(files(i_found).name(1:14),'%4d%2d%2d%2d%2d%2d')';
                  t_file = utc2sidt(t_file(1:3),t_file(4:end));
                  
                  while i_found < length(files) && t_file < t_start
                    i_found = i_found + 1;
                    t_file = sscanf(files(i_found).name(1:14),'%4d%2d%2d%2d%2d%2d')';
                    t_file = utc2sidt(t_file(1:3),t_file(4:end));
                  end
                  while  i_found < length(files) &&  t_file < t_stop
                    % filenames = {filenames{:},fullfile(ALIS_data_dir,y_str,m_str,d_str,h_str,files(i_found).name)};
                    filenames = [filenames,{fullfile(ALIS_data_dir,y_str,m_str,d_str,h_str,files(i_found).name)}];
                    i_found = i_found + 1;
                    t_file = sscanf(files(i_found).name(1:14),'%4d%2d%2d%2d%2d%2d')';
                    t_file = utc2sidt(t_file(1:3),t_file(4:end));
                  end
                  cd('..')
                catch
                end
              end
            
              cd('..')
            catch
          end
          
          end
        cd('..')
        catch
        end
        
      end
      cd('..')
    catch
    end
  end
  if ~isempty(filenames)
    Filenames{end+1} = str2mat(filenames);
  end
end
