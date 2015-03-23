function o = nothing2obs(filename)
% NOTHING2OBS - Observation struct from nothing,
%  arbitrary default values are hardcoded to the necessary
%  fields. This should be seen as an instructive example of what
%  fields are necessary output from the image readning function to
%  make the STARCAL function work properly.
%  FILENAME is used as an empty input...
%   
% OUTDATED!

o.time = [2008 2 26 4 0 2];
o.pos = [-145 62.5];
o.longlat = [-145 62.5];
o.station = 15;
o.camnr = 0;
o.beta = 0;
o.alpha = 0;
o.az = 0;
o.ze = 0;
o.exptime = nan;
o.filter = 5577;
