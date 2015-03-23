function SkMp = loadparam(SkMp, model, stnn)
% LOADPARAM - loads parameters for lens model tests and 
%							saves them into an acc file. 
%
%	SYNOPSIS
%
%				SkMp = loadparam(SkMp, model, stnn)
%
%				loads preliminary optical parameters file and saves the relevant
%				parts to an acc file. this function is not intended for general
%				use. intended use basicly is in scripts and data mining from
%				large amounts of prel optpar files.

% Copyright © M V 2010

paramfile = genfilename(SkMp, 2);
savefile = genfilename(SkMp,1);
parampath = ['lens_tests/model_', num2str(model), '/', stnn, '/'];
params = [parampath paramfile];
accsave = [parampath savefile];
load(params)
SkMp.identstars = identstars_saved;
SkMp.optpar = optpar_saved;
SkMp.optmod = optmod_saved;
saveok = saveas_acc(SkMp.optpar, ...
                    SkMp.obs.time, ...
                    accsave, ...
                    SkMp.obs.station, ...
                    SkMp.obs.az, ...
                    SkMp.obs.ze, ...
                    SkMp.optmod);
