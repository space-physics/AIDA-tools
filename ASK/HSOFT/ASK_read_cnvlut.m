function [cnv_t1,cnv_t2,cnv_data] = ASK_read_cnvlut(filename)
% ASK_READ_CNVLUT - reads the camera parameter lookup table
%
% Calling:
%   [cnv_t1,cnv_t2,cnv_data] = ASK_read_cnvlut(filename)
% Input:
%  filename - name of cnv-file, typically something like
%             /stp/raid2/ask/data/setup/camera[123].lut
%  Output:
%   cnv_t1   - Start time of camera parameters (MJS)
%   cnv_t2   - Stop time of camera parameters (MJS)
%   cnv_data - Camera parameters

% Written to mimic read_cnvlut.pro
% Copyright Bjorn Gustavsson 20110207
% GNU Copyleft 3.0 or later applies.

% Must be DECLARATION OF:
% common cnvlut, cnv_t1, cnv_t2, cnv_data

global cnvlut % FOR: cnv_t1 cnv_t2 cnv_data


fid = fopen(filename,'r');
if fid == -1
  error(['could not open file: ',filename])
end

% Date format is: day/month/year hh:mm:ss
formatStr = '%f/%f/%f %f:%f:%f %f/%f/%f %f:%f:%f %f %f %f %f %f %f %f %f';
CNV = textscan(fid,formatStr,'CommentStyle','#');
% So here we resort them into yyyy, mm, dd, HH...
cnv_t1 = [CNV{3},CNV{2},CNV{1},CNV{4},CNV{5},CNV{6}];
cnv_t2 = [CNV{9},CNV{8},CNV{7},CNV{10},CNV{11},CNV{12}];

cnv_data = [CNV{13},CNV{14},CNV{15},CNV{16},CNV{17},CNV{18},CNV{19},CNV{20}];

cnv_t1 = ASK_TT_MJS(cnv_t1);%(:,[3,2,1,4,5,6]));
cnv_t2 = ASK_TT_MJS(cnv_t2);%(:,[3,2,1,4,5,6]));

fclose(fid);

cnvlut.cnv_t1 = cnv_t1;
cnvlut.cnv_t2 = cnv_t2;
cnvlut.cnv_data = cnv_data;
