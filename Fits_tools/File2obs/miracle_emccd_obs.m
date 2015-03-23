function [obs]=miracle_emccd_obs(h)
% MIRACLE_EMCCD_OBS - build obs-struct for MIRACLE eMCCD images

%Build struct header.keyword='value' (NB: strings)
%In this way sorting and searching can be avoided.
vals = {h{:,2}};
keywords = {h{:,1}};
%workaround: no "operators" or brackets allowed in struct field names
keywords = strrep(keywords,'(','');
keywords = strrep(keywords,')','');
keywords = strrep(keywords,'-','');
header = cell2struct(vals,keywords,2);

%Time: array [yyyy,mo,dd,hh,mm,ss.ms], average of start and stop times
start = datenum([header.Date,header.TimeStart1],'yyyy-mm-ddHH:MM:SS.FFF');
if ~isempty(str2num(header.TimeStop2))
  stop = datenum([header.Date,header.TimeStop2],'yyyy-mm-ddHH:MM:SS.FFF');
else
  stop = datenum([header.Date,header.TimeStop1],'yyyy-mm-ddHH:MM:SS.FFF');
end
obs.time = str2num(datestr(mean([start stop]),'yyyy mm dd HH MM SS.FFF'));

%remember, brackets were stripped, so it's Filternm, not Filter(nm)
obs.filter = header.Filternm; %character string!
%Exposure time, from string (n*BaseExp)
%Likewise Exposures, not Exposure(s)
obs.exptime = eval(header.Exposures); %value! 


%station and camera number - for now both numbers are the same
%NB:KIL location changed fall 2009 -> station number changes from 740 to 741
stn_name = {'SOD','SGO','MUO','ABK','KIL1','KIL2','KEV','LYR','NAL'};
stn_num =  [  710, 711,  720,  730,   740,   741,  750,  760,  770];

sn=header.Station;

%Kilpis station move
if strcmp(sn,'KIL') & obs.time(1) == 2009 & obs.time(2) < 6
  sn = 'KIL1';
elseif strcmp(sn,'KIL') & obs.time(1) ==2009 & obs.time(2) > 8
  sn = 'KIL2';
end

isn = strcmp(sn,stn_name);
obs.station = stn_num(isn);
obs.camnr = stn_num(isn); 

%Read in the .stations files (Reports full station names)
[long,lat,alts,StnNames,stnNR] = station_reader();

isn = find(stnNR == obs.station);

obs.longlat = [long(isn) lat(isn)];
obs.pos = [long(isn) lat(isn)];

obs.beta = [];
obs.alfa = [];
%Could search for usual rotation angles here as well...
obs.az = 0.;
obs.ze = 0.;

%Guess optical parameters: ASC no rotations
obs.optpar = [0.25 -0.25 0 0 0 0 0 0.5];
obs.optmod = 2;
%%%%
