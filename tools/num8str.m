function [s] = num8str(in)
% NUM8STR - numerical to string converter
% 
% NUM8STR is a higher precision version 
% of the matlab function num2str.

%       Bjorn Gustavsson
%	Copyright (c) 1997 by Bjorn Gustavsson

s = sprintf('%.8g',in);
