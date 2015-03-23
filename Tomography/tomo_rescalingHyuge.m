function [C,I_los] = tomo_rescalingHyuge(I_img,e_los,I3D,X,Y,Z,r0)
% TOMO_RESCALINGHYUGE - rescale volume emission rate to correct l-o-s intensity
%   
% Calling:
%  C = tomo_rescaling(I_img,I3D,X,Y,Z,r0,e_los)
% 
% Input:
%  I_img - image intensity in Rayleighs
%  I3D
% 

%   Copyright © 2008 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


for i1 = 1:size(Z,3),
  
  l = (Z(1,1,i1)-r0(3))/e_los(3);
  L(i1) = l;
  r_los = point_on_line(r0,e_los,l);
  
  % I_los = interp3(X,Y,Z,I3D,r_los(1,:),r_los(2,:),r_los(3,:));
  I_los(i1) = interp2(X(:,:,i1),Y(:,:,i1),I3D(:,:,i1),r_los(1),r_los(2));
  
end
I_los(~isfinite(I_los)) = 0;

I_col = sum(I_los.*gradient(L*1e3));

C = 1e10*I_img/I_col;
