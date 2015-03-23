function [h,d] = imwrapper(filename)
% IMWRAPPER - simple wrapping function for image reading 
h = [];
d = imread(filename);
