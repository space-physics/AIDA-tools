function [Imax,i1,i2] = max2D(Iin)
% max2D - maximum element and its indices in a 2-D array
%
% Callling:
%   [Imax,i1,i2] = max2D(Iin)
% Input:
%   Iin - 2-D array [n1 x n2]
% Output:
%   maxI - maximum value in Iin [1 x 1]
%   i1   - index along dimension 1 of maxI
%   i2   - index along dimension 2 of maxI
%          such that maxI = Iin(i1,i2)
% Example
%   Iin = randn(29,31);
%   [Imax,i1,i2] = max2D(Iin);
%   max(Iin(:)) == Imax && Iin(i1,i2) == Imax

% Very exciting function!
[maxI1D,i1] = max(Iin);
[Imax,i2] = max(maxI1D);
i1 = i1(i2);
