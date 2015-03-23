function bfk = base_fcn_kernel(ks)
% BASE_FCN_KERNEL - gives 1-D footprints of 3-D base functions
% in a cell-array.
% 
% Calling:
%  bfk = base_fcn_kernel(ks)
%
% See also FASTPROJECTION,  

%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

for i1 = length(ks):-1:1,
  
  bfk{i1} = sin(pi*[0:(2*ks(i1))]/ks(i1)/2).^2;
  bfk{i1} = bfk{i1}/sum(bfk{i1});
  
end
