function [cnv,cnvscale] = ASK_get_cnv()
% ASK_GET_CNV - gets the cnv from the vs common block and returns it in
% cnv. scale is also returned, which is the angular resolution in
% degrees/pixel. 
%   
% Calling:
%   [cnv,cnvscale] = ASK_get_cnv
% Input:
%   None. 
% Output:
%   cnv      - camera parameters
%   cnvscale - camera scaling parameters
%
% Function takes the camera parameters from the global struct: vs

% Written to mimic get_cnv.pro
% Copyrigth Bjorn Gustavsson 20110207
% GNU Coplyleft 3.0 or later applies.

global vs
cnv = vs.vcnv(vs.vsel,:);
cnvscale = cnv(2)*1e-3 * 180/pi;% /!dtor
