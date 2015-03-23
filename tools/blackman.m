function w = blackman(varargin)
% BLACKMAN - blackman window (of length L)
% SYNOPSIS:
% 					w = blackman(L);
% 					w = blackman(L, a);
%
%	if only one parameter is given, the result will be the classic
%	blackman window. this is usually what the user wants anyway.
%

alpha = 0.16;
L = varargin{1}-1;

if nargin ~= 1
 alpha = varargin{2};
end

a0 = (1-alpha)/2;
a1 = 0.5;
a2 = alpha/2;

w = a0 - a1*cos((2*pi*(0:L))/L) - a2*cos((4*pi*(0:L))/L);
