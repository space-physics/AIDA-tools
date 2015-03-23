function t = ASK_time_v(i1,fullMJS)
% ASK_TIME_V - returns time since the start of the sequence
%
%  keyword full forces the time to be mjs, rather than seconds from the start
%
% Calling:
%   t = ASK_time_v(i1,fullMJS)

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies
global vs

t = vs.vres(vs.vsel) *( i1 - vs.vnf(vs.vsel) );
if nargin == 2 && fullMJS
  t = vs.vmjs(vs.vsel)+1.0*t;
end
