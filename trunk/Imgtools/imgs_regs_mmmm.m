function [I_max,I_mean,I_median,I_min,Tr_time,expt,filters] = imgs_regs_mmmm(files,regs,OPS,PO)
% imgs_regs_mmmm - max, mean, median and min from regions in an image-serie
% 
% Calling:
% [I_max,I_mean,I_median,I_min,Tr_time,expt,filters] = imgs_regs_mmmm(files,regs,OPS,PO)
% 
% Iput arguments:
%   FILES  - char array of image files, full or relative path, readable 
%   REGS   - image regions (Nx4) of [xmin xmax ymin ymax] to get stats from
%   OPS    - options structure currently only OPS.wb, if 1 use
%            waitbar to show time left
%   PO - image pre_proc_ops see TYPICAL_PRE_PROC_OPS
%   
%   Very little or no argument checking is preformed
%
%  See also: STARCAL, CAMERA, TYPICAL_PRE_PROC_OPS
%

%   Copyright � 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin == 0
  
  % In case of no input arguments give OPS structure in return
  I_max.wb = 0;
  return
  
end

if nargin < 4
  PO = typical_pre_proc_ops;
end

wbh = [];
if ~isempty(OPS) && OPS.wb
  wbh = waitbar(0,'Working');
end


I_mean = zeros([size(files,1),size(regs,1)]);
I_median = I_mean;
I_min = I_mean; 
I_max = I_mean;

for i1 = size(files,1):-1:1,
  
  [data1,head1,o] = inimg(files(i1,:),PO);
  
  expt(i1) =  o.exptime;
  if expt(i1)<100
    expt(i1) = 1000*expt(i1);
  end
  tid = o.time;%_from_header(head1);
  
  % Major anoyance makes it smoother when observations go round midnight!
  Tr_time(i1) = tid(3)*24+tid(4)+tid(5)/60+tid(6)/3600;
  if ~isempty(o.filter)
    filters(i1) = o.filter;
  else
    filters(i1) = nan;
  end
  for j1 = size(regs,1):-1:1,
    
    I_mean(i1,j1) = mean(mean(data1(regs(j1,3):regs(j1,4),regs(j1,1):regs(j1,2))));
    I_median(i1,j1) = median(median(data1(regs(j1,3):regs(j1,4),regs(j1,1):regs(j1,2))));
    I_min(i1,j1) = min(min(data1(regs(j1,3):regs(j1,4),regs(j1,1):regs(j1,2))));
    I_max(i1,j1) = max(max(data1(regs(j1,3):regs(j1,4),regs(j1,1):regs(j1,2))));
    
  end
  if ~isempty(wbh)
    ratio = i1/size(files,1);
    waitbar(ratio,wbh)
  end
  
end

if ~isempty(wbh)
  close(wbh)
end
