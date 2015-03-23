function obs = Kosch_in_ramfjord(filename)
% KOSCH_IN_RAMFJORD - make Observation struct from filename
%   
% WARNING Outdated! should be fixed before usage...

persistent Station_names
persistent stationpos

if isempty(stationpos)
  load stationpos.dat
end

station = 11;

obs.time = [2005 10 8 21 20 20];
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
obs.camnr = [37];
obs.exptime = 1/25;
obs.filter = [];
obs.imreg = [73 648     1   576];
obs.cmtr = eye(3);
