
ASK_site_setup

% TODO: move this one out of here, this is an initialization call,
% not a set-up, shouldn't be here!
% * step 1: find out where it the script is called and change that
%   to ASK_site_setup, ASK_site_init or some such
% * step 2: then put this line into the ASK_site_init.m
ASK_read_asklut(ASKLUTfile);
% * step 3 move the other hard-coded set-ups into this and this
%   script into these places.