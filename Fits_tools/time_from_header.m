function [time,timestr] = time_from_header(header)
% TIME_FROM_HEADER parses a ALIS header for time
% Usually/hopefully compatible with all ALIS versions.
%
% Calling:
%  [time] = time_from_header(header)
% 
% Input:
%  HEADER - fits header


%   Copyright © 2001-2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

delimiters = [9:13 32];
delimiters = [delimiters,'~=+*/^()[]{}<>,;:'''];


H = header;

hindx = fitsfindinheader(H,'DATE-OBS');

if ~isempty(hindx)
  delimiters = [delimiters,'-T'];
  timestr = H(hindx,12:end);
  [year,timestr] = strtok(timestr,delimiters);
  [month,timestr] = strtok(timestr,delimiters);
  [day,timestr] = strtok(timestr,delimiters);
  [hour,timestr] = strtok(timestr,delimiters);
  [minute,timestr] = strtok(timestr,delimiters);
  [sec,timestr] = strtok(timestr,delimiters);
  time = str2num([year,month,day,hour,minute,sec]);
  
else
  
  % Didn't find 'DATE-OBS' keyword now looking for old nonstandard
  % time keyword used by 'ALIS' pre 1998 something...
  hindx = fitsfindinheader(H,'ALIS-UTC');
  if ~isempty(hindx)
    timestr = H(hindx,12:end);
    [gps_class,timestr] = strtok(timestr,':');
    [year,timestr] = strtok(timestr,delimiters);
    [month,timestr] = strtok(timestr,delimiters);
    [day,timestr] = strtok(timestr,delimiters);
    [hour,timestr] = strtok(timestr,delimiters);
    [minute,timestr] = strtok(timestr,delimiters);
    [sec,timestr] = strtok(timestr,delimiters);
    time = 1900 + str2num([year,month,day,hour,minute,sec]);
    
  else
    % when everything else fails ask...
    datestr = 'Date of observation (YYYY , MM , DD)';
    timestr = 'Time of observation (UT) (HH , MM , SS.dd)';
    defll = {'1990 12 24','15  07  12'};
    title = 'OBSERVATION TIME?';
    lineNo=1;
    answer=inputdlg({datestr,timestr},title,lineNo,defll);
    time = [ str2num(answer{1}) str2num(answer{2})];
    
  end
  
end
