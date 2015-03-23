function obs = Kari_in_Ramfjord20011112(header)
% Kari_in_Ramfjord20011112 - make Observation struct from filename
%   for Kari Kaila's images from the 2001-11-12 observations at
%   Ramfjord.

persistent Station_names
persistent stationpos

if isempty(stationpos)
  load stationpos.dat
end

station = 11;

obs.time = [sscanf(header(fitsfindinheader(header,'DATE-OBS'),12:25),'%d-')',...
            sscanf(header(fitsfindinheader(header,'TIME-OBS'),12:25),'%d:')'];
obs.longlat = [sum(stationpos(station,5:7).*[1 1/60 1/3600])* ...
               stationpos(station,8) ...
               sum(stationpos(station,1:3).*[1 1/60 1/3600])* ...
               stationpos(station,4)];
obs.longlat = obs.pos;
obs.station = 11;
obs.alpha = [];
obs.beta = [];
obs.az = [180];
obs.ze = [12];
obs.camnr = [38];
obs.exptime = 3;
obs.filter = [];
obs.imreg = [];
obs.BZERO = str2num(header(fitsfindinheader(header,'BZERO'),12:end));
