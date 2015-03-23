function obs = MK_at_HAARP2008(filename)
% MK_at_HAARP2008 - make Observation struct from file-struct
%   Everything hard-coded for one particular image from a HAARP
%   campaign. 
% 
% Also outdated!

obs.time = [2007 3 16 19 32 67];
obs.pos= [62.3 -145.25];
obs.longlat= [62.3 -145.25];
obs.xyz = [0,0,0];
obs.station = 401;
obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [39];
obs.exptime = 2;
obs.filter = [];
obs.imreg = [];
obs.BZERO = 0;

