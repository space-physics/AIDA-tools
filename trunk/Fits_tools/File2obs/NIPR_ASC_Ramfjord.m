function obs = NIPR_ASC_Ramfjord(filename)
% NIPR_ASC_Ramfjord - make Observation struct from filename
%   Set up to initialize an OBS-struct for the NIPR all-sky imager
%   in Ramfjord. Queries for observation time.

persistent Station_names
persistent stationpos

qe = imread(filename);
imagesc(qe)
if isempty(stationpos)
  load stationpos.dat
end

station = 11;
obs.time = in_def2('date-n-time?',[2005 10 8 21 20 20]);

obs.longlat = [sum(stationpos(station,5:7).*[1 1/60 1/3600])* ...
               stationpos(station,8) ...
               sum(stationpos(station,1:3).*[1 1/60 1/3600])* ...
               stationpos(station,4)];
obs.pos = obs.longlat;

obs.station = 11;
obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [38];
obs.exptime = 1/25;
obs.filter = [];
obs.imreg = [121 600     1   480];
obs.cmtr = eye(3);
