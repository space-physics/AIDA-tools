function events = alis_event_reader(filename)
% ALIS_EVENT_READER - parse event-list for automatic data-processing
%   
% Calling:
%   events = alis_event_reader(filename)
% Input:
%   filename - filename of event listing
% Output:
%   events - struct array with dates, start and stop time, stations
%            with observations and description
%
% Sample event file format:
% 
% # date   start-t stop-t        ALIS-data Description-ASK
% 20061020171700  20061020171900 ABSKOT   bright arc
% 20061020170000  20061020170200 X        Low energy arc



%   Copyright © 2007 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

fp = fopen(filename,'r');

events = [];
while ~feof(fp)
  
  cline = fgetl(fp);
  if ~isempty(cline)
    if cline(1) == '#'
      % Comment
    else
      [date1,cline] = strtok(cline,' ');
      [date2,cline] = strtok(cline,' ');
      [stns,cline] = strtok(cline,' ');
      if ~strcmp(stns,'X')
        events(end+1).date = sscanf(date1(1:8),'%4d%2d%2d')';
        events(end).start_time = sscanf(date1,'%4d%2d%2d%2d%2d%2d')';
        events(end).stop_time = sscanf(date2,'%4d%2d%2d%2d%2d%2d')';
        events(end).stns = deblank(stns);
      end
    end
  end
end
fclose(fp);
