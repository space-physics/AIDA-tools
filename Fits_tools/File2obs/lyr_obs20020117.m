function o = lyr_obs20020117(filename)
% LYR_OBS20020117 - Observation struct from filename
%   This function sets the fields for observations from LYR at
%   2002-01-17, and counts the time from 2002 01 17 06 46 10 with
%   25 frames/s.

f_dir = fileparts(filename);
f_names = dir(fullfile([f_dir],'*.png'));
t0 = [2002 01 17 06 46 10];

f_indx = find_in_cellstr(filename,{f_names(:).name});


o.time = t0 + [0 0 0 0 0 1/25*(f_indx-1)];
o.pos = [16+2/60 78+9/60];
o.longlat = [16+2/60 78+9/60];
o.station = 12;
o.camnr = 0;
o.beta = 0;
o.alpha = 0;
o.az = 180;
o.ze = 8;
o.exptime = 1/25;
o.filter = -1;
