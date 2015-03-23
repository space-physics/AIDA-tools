function [I_max,I_mean,I_median,I_min] = imgstack_regs_mmmm(img_stack,regs)
% imgstack_regs_mmmm - max, mean, median and min from regions in an image-stack
% 
% Calling:
% [I_max,I_mean,I_median,I_min] = imgstack_regs_mmmm(img_stack,regs)
% 
% Iput arguments:
%   FILES  - char array of image files, full or relative path, readable 
%   REGS   - image regions (Nx4) of [xmin xmax ymin ymax] to get stats from
%   
%   Very little or no argument checking is preformed
%
%  See also: STARCAL, CAMERA, TYPICAL_PRE_PROC_OPS
%


%   Copyright © 20080505 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

I_mean = zeros([size(img_stack,3),size(regs,1)]);
I_median = I_mean;
I_min = I_mean; 
I_max = I_mean;

for i1 = 1:size(img_stack,3),
  
  for j2 = size(regs,1):-1:1,
    
    data1 = img_stack(regs(j2,3):regs(j2,4),regs(j2,1):regs(j2,2),i1);
    I_mean(i1,j2) = mean(data1(:));
    I_median(i1,j2) = median(data1(:));
    I_min(i1,j2) = min(data1(:));
    I_max(i1,j2) = max(data1(:));
    
  end
  
end
