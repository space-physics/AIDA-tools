function [l_cl,cl_sz] = sc_grouping(vs,nr_layers)
% SC_GROUPING - divides base functions into NR_LAYER groups
% based on sizes VS
% 
% Calling:
% [l_cl,cl_sz] = sc_grouping(vs,nr_layers)
% 

%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if ( diff([min(vs(:)) max(vs(:))]) )
  
    % need to add something here which will set a nan wherever vs = 256
    % (blob size of 256 pixels is not physical for z > ~0.5km) our min z
    % will never be below 75km, so blobs of > ~50 pixels is not realistic.
    
  %indx_256 = find(vs == 256);   
  vs(vs==256) = NaN;    % addition for the comment above
    
  sizelimits = min(vs):(max(vs)-min(vs))/(nr_layers):max(vs);
  
  for i1 = 1:(nr_layers),
    
    l_cl{i1} = find(sizelimits(i1)<=vs&vs<=sizelimits(i1+1));
    
  end
  
  cl_sz = (sizelimits(1:end-1)+sizelimits(2:end))/2;
  
  % these lines added so that all blobs in volume are accounted for in l_cl
  l_cl{nr_layers+1} = find(isnan(vs) == 1); % find the blobs outside image
  cl_sz(nr_layers+1) = 0;   % set the footprint size of blobs outside image to zero
  
else
  
  l_cl{1} = 1:length(vs);
  cl_sz = mean(vs);
  
end
