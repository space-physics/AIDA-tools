function OPTS = spc_typical_ops
% SPC_TYPICAL_OPS - Provides a struct with typical options
% OPS.maglimit is the limit in magnitude for stars to search for,
% OPS.regsize is the size of the image region surounding a star to
% use for background calculation, OPTS.bgtype is a string with
% either 'complicated' for a more complex background calculation or
% something else for as simple.
%
% Calling:
% OPTS = spc_typical_ops
% 


%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

OPTS.Mag_limit = 5; % Brighness limit of stars to search for
OPTS.regsize = 10; % image region around stars used for background reduction
OPTS.bgtype = 'simple';  %[ {'simple'} | 'complicated' ];
OPTS.starscatter = 2; % Acceptance region, in pixels, of identified
                      % stars
OPTS.check_ids = 0; % Check the identified stars one by one in each
                    % image frame.
OPTS.pausetime = 0;
