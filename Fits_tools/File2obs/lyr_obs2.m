function o = lyr_obs2(filename)
% LYR_OBS - Observation struct from filename
%   This function sets the fields for observations from LYR at
%   2005-12-03, and counts the time from 2005 12 03 15 57 00 with
%   25 frames/s.
%   

f_dir = fileparts(filename);
f_names = dir(fullfile([f_dir],'*.png'));
t0 = [2005 12 3 15 57 0];

f_indx = find_in_cellstr(filename,{f_names(:).name});


o.time = t0 + [0 0 0 0 0 1/25*(f_indx-2)];
o.longlat = [16+2/60 78+9/60];
o.pos = [16+2/60 78+9/60];
o.station = 12;
o.camnr = 0;
o.beta = 0;
o.alpha = 0;
o.az = 180;
o.ze = 8;
o.exptime = 1/25;
o.filter = -1;
