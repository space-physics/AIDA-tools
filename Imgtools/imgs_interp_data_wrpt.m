function [d,h,o] = imgs_interp_data_wrpt(files,times,t0)
% IMGS_INTERP_DATA_WRPT - estimate image intensities at t0 from image-sequence
%   
% Calling: [d,h,o] = imgs_interp_data_wrpt(files,times,t0)
% 
% Input:
%  files - array of image filenames
%  times - time of exposures
%  t0    - time for which to guesstimate the image intensity


%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
