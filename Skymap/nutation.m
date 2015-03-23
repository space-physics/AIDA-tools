function [N] = nutation(Obsdate,utc)
% NUTATION calculates the nutation 
% and other higher order corrections.
% Clearly out of the scope for my needs.
% But left for the carefull and ambitious users
% to replace/fill in with something more
% (well...) accurate. 
% 
% Calling:
% [N] = nutation(date,utc)


%   Copyright © 19990219 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


N = eye(3);
