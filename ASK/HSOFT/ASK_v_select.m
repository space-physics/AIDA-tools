function ASK_v_select(indx,quiet)
% ASK_V_SELECT - Set current camera index in global structure VS
%   
% Calling:
%   ASK_v_select(indx)

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs

max_camera_number = length(vs.vnf);

% Constrain indx to be between 1 and the maximum camera number:
indx = max(1,min(max_camera_number,indx));

vs.vsel = indx;
ASK_get_imcal
if nargin == 1 | ( quiet == 0 & ~strcmp(quiet,'quiet'))
  ASK_v_summary
end
