function M_out = ASK_bytscl(M_in,min_in,max_in,max_out)
% ASK_BYTSCL - clip-n-scale matrix into [0-MAXOUT] from min(max_IN,max(min_IN,M_in))
%   
% Calling:
%   M_OUT_out = ASK_bytscl(M_IN,MIN_IN,MAX_IN,MAX_OUT)
% Input:
%  M_IN    - double array [N x M]
%  MIN_IN  - double scalar for lowest value to scale to 0. If empty
%            or absent min(M_IN(:)) is used.
%  MAX_IN  - double scalar for biggest value to scale to MAX_OUT. If empty
%            or absent max(M_IN(:)) is used.
%  MAX_OUT - value to scale MAX_IN to

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

if nargin < 2 | isempty(min_in)
  min_in = min(M_in(:));
end
if nargin < 3 | isempty(max_in)
  max_in = max(M_in(:));
end
if nargin < 4 | isempty(max_out)
  max_out = 1;
end

M_out = ( min(max_in,max(min_in,M_in)) - min_in)/( max_in - min_in) * max_out;
