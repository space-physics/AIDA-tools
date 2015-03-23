function o = Lyr2obs(filename,t0,longlat)
% LYR_OBS - Observation struct from filename
%   This function sets the fields for observations from LYR at
%   2005-12-03, and counts the time from 2005 12 03 15 57 00 with
%   25 frames/s.
%   

if nargin < 2 | isempty(t0)
  t0 = [2005 12 3 15 57 0];
end
if nargin < 3 | isempty(longlat)
  longlat = [16+2/60 78+9/60];
end

f_dir = fileparts(filename);

f_names = dir(fullfile([f_dir],'*.png'));
qwe = str2mat({f_names.name});
[qwe,idx] = sortrows(qwe);
f_names = f_names(idx);

f_indx = find_in_cellstr(filename,{f_names(:).name});


o.time = t0 + [0 0 0 0 0 1/25*(f_indx-2)];
o.longlat = longlat;
o.longlat = o.pos;

o.station = 12;
o.camnr = 0;
o.beta = 0;
o.alpha = 0;
o.az = 180;
o.ze = 8;
o.exptime = 1/25;
o.filter = -1;
