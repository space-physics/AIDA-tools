function [stns,Vem] = adjust_level(stns,Vem,doit_eh)
% ADJUST_LEVEL - Scale 3D intensities to give projections that have
% the same total intensity as the images. 
%   
% Calling:
% [stns,Vem] = adjust_level(stns,Vem,doit_eh)
% 


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

for i1 = 1:length(stns),
  
  imgsize = size(stns(i1).img);
  if isfield(stns,'sens_mtr')
    stns(i1).proj = fastprojection(Vem,stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk,imgsize,stns(i1).sens_mtr,stns(i1).sz3d);
  else
    stns(i1).proj = fastprojection(Vem,stns(i1).uv,stns(i1).d,stns(i1).l_cl,stns(i1).bfk,imgsize);
  end
end

if doit_eh
  
  isum = 0;
  psum = 0;
  for i1 = 1:length(stns),
    
    isum = isum + sum(stns(i1).img(:));
    psum = psum + sum(stns(i1).proj(:));
    
  end
  
  Vem = Vem*isum/psum;
  for i1 = 1:length(stns),
    
    stns(i1).proj = stns(i1).proj*isum/psum;
    
  end
  
end
