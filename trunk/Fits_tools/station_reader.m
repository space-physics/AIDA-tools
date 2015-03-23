function [long,lat,alts,StnNames,stnNR] = station_reader()
% STATION_READER - collects station number, name, long, lat  
% and altitude from all *.stations files in AIDA_root/.data.
% The stations file format is:
%  StNr Station-name long-deg long-minute long-sec NS lat-deg lat-minute lat-sec alt 
% See ALIS.stations, Miracle.stations for examples.
% 
% Calling:
%   [long,lat,alts,StnNames,stnNR] = station_reader()


%   Copyright © 20090214 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Path to the AIDA_tools data directory
AIDA_datadir = fileparts(which('ALIS.stations'));

% List of all the stations files
% StationFiles = dir(fullfile(AIDA_datadir,'Stations','*.stations'));
StationFiles = dir(fullfile(AIDA_datadir,'*.stations'));

for i1 = length(StationFiles):-1:1,
  
  filename = fullfile(AIDA_datadir,StationFiles(i1).name);
  % Read all the files, the %q reads a (possibly double quoted)
  % string
  [Snr,names,l1,l2,l3,ls,L1,L2,L3,alt]=textread(filename,...
                                                '%n%q%n%n%n%d%n%n%n%n',...
                                                'commentstyle','matlab');
  long{i1} = ls.*( l1 + l2/60 + l3/3600);
  lat{i1} = sign(alt).*( L1 + L2/60 + L3/3600);
  alts{i1} = alt;
  StnNames{i1} = names;
  stnNR{i1} = Snr;
  
end
long = cat(1,long{:});
lat = cat(1,lat{:});
alts = cat(1,alts{:});
StnNames = cat(1,StnNames{:});
stnNR = cat(1,stnNR{:});
