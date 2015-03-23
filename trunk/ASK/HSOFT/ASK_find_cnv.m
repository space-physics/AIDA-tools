function cnv = ASK_find_cnv(mjs_time)
% ASK_FIND_CNV - get the cnv camera parameters for a specific time
% from the common block
% This is for ASK, where cnv values are inside a lookup table.
%
% Calling:
%  cnv = ASK_find_cnv(mjs_time,cnv_t1,cnv_t2,cnv_data)
% Input:
%  mjs_time - the time of interest
%  cnv_t1   - Start time of CNV-validities
%  cnv_t2   - Stop time of CNV-validities
%  cnv_data - CNV-parameters.
% Output:
%  cnv - the camera/conversion parameters


% Written to mimic find_cnv.pro
% Copyright Bjorn Gustavsson 20110207
% GNU copyleft version 3.0 or later applies

% function cnv = find_cnv(mjs_time,cnv_t1,cnv_t2,cnv_data)


global cnvlut % WITH: cnv_t1, cnv_t2, cnv_data

%[start_indx,stop_indx] = ASK_locate_int(cnvlut.cnv_t1,cnvlut.cnv_t2,mjs_time,mjs_time);
[start_indx] = ASK_locate_int(cnvlut.cnv_t1,cnvlut.cnv_t2,mjs_time,mjs_time);
cnv = cnvlut.cnv_data(start_indx,:);
