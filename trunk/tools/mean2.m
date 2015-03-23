function y = mean2(x)
%MEAN2 Compute mean of matrix elements.
%   B = MEAN2(A) computes the mean of the values in A.
%
%   Class Support
%   -------------
%   A is an array of class uint8 or double. B is a scalar of
%   class double.
%
%   See also MEAN, STD, STD2.

%   Copyright © 2031-07-17 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

y = mean(x(:));
