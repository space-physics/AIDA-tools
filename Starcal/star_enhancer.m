function Df = star_enhancer(files,PO,i0,nr_imgs,filtersizes)
% STAR_ENHANCER - average background-removed images to enhance stars 
%   
% Calling:
%  Df = star_enhancer(files,PO,i0,nr_imgs{,filtersize})
% Input:
%  files - string array, [nr_imgs,n], or array with structs as
%          returned from "dir"
%  PO - struct with pre-processing options, SEE: typical_pre_proc_ops
%  i0 - index to file around which to center the star enhancement
%  nr_imgs - number of images to add, the images from 
%            files(i0+[-floor(nr_imgs/2):floor(nr_imgs/2)]) will be
%            used.
% filtersize - [fs_median, fs_wiener] 2 scalars for filtersize of
%              the median and wiener/Lee/Sigma
%              filter-regions. Optional, defaults are [7 3]
% 
% The algorithm reads the images, from each image a 7-by-7 median
% filtered is subtracted, the difference is then filtered with
% wiener2 (Lee's sigma filter) with a 3-by-3 region. These are then
% added together. The idea is that by subtracting the
% medianfiltered version the difference should be only stars and
% noise. Wiener2 and the averagin is used to reduce noise.


%   Copyright � 2009 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   and Cyril Simon, <Cyril.Simon@aeronomie.be>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 5
  filtersizes = [7 3];
end
NR = floor(nr_imgs/2);
Df = 0;

for i1 = -NR:NR,
  
  %[d,h,o] = inimg(files(i0+i1,:),PO);
  if isstruct(files)
    d = inimg(files(i0+i1).name,PO);
  else
    d = inimg(files(i0+i1,:),PO);
  end
  Df = Df + wiener2(d-medfilt2(d,filtersizes(1)*[1,1]),filtersizes(2)*[1,1]);
  
end

  
