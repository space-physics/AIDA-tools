function [data_field1,data_field2] = imgs_deinterlace(data)
% IMGS_DEINTERLACE - Deinterlace 2-field video-frames
%
% Calling:
%   [data_field1,data_field2] = imgs_deinterlace(data)
% Input:
%   DATA - interlaced image [NxM], that is every second line
%          corresponds to two exposures at different times.
% Output:
%   DATA_FIELD1,DATA_FIELD2 (both [NxM]) are the deinterlaced
%   fields, linearly interpolated to the original resolution.
% 
%   The function assumes that the first frame is data(2:2:end,:);


%   Copyright © 20061006 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

nrlines = size(data,1);
data_field1 = data(2:2:end,:);
data_field2 = data(1:2:end,:);

data_field1 = interp1(2:2:nrlines,data_field1,1:nrlines,'linear','extrap');
data_field2 = interp1(1:2:nrlines,data_field2,1:nrlines,'linear','extrap');
