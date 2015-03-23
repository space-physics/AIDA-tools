function obs = Kosch_inSkibotn20011112(header)
% KOSCH_IN_RAMFJORD - make Observation struct from filename
%   

persistent Station_names
persistent stationpos

if isempty(stationpos)
  load stationpos.dat
end

station = 10;

obs.time = [sscanf(header(fitsfindinheader(header,'DATE-OBS'),12:end),'%d-%d-%dT%d:%d:%d')'];
obs.longlat = [sum(stationpos(station,5:7).*[1 1/60 1/3600])* ...
               stationpos(station,8) ...
               sum(stationpos(station,1:3).*[1 1/60 1/3600])* ...
               stationpos(station,4)];
obs.pos = obs.longlat;
obs.station = station;
obs.alpha = [];
obs.beta = [];
obs.az = [180];
obs.ze = [12];
obs.camnr = [38];
obs.exptime = 3;
obs.filter = [];
obs.imreg = [];
obs.BZERO = str2num(header(fitsfindinheader(header,'BZERO'),12:end));
