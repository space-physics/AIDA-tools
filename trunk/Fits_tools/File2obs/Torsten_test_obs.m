function obs = Torsten_test_obs(filename)
% Torsten_test_obs - make Observation struct from file-struct
%   Everything hard-coded, except it takes the observation-time
%   from the date of the file creation.
%   

file = dir(filename);
obs.time = file.date;%[2007 3 16 19 32 67];
obs.pos = [69.5 18.0];
obs.longlat = [69.5 18.0];
obs.station = 0;
obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [39];
obs.exptime = 2;
obs.filter = [];
obs.imreg = [];
obs.BZERO = 0;
