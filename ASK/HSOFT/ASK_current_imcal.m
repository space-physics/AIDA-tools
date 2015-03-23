function [dark,fmd] = ASK_current_imcal()
% ASK_CURRENT_IMCAL - get the dark and flat from the common block
% dark and fmd (flat) are outputs.
%   
% Calling:
%  [dark,fmd] = ASK_current_imcal

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global imcal

dark = imcal.d_field;
fmd  = imcal.fmd_field;
