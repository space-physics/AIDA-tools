function [CalFactors,stns,calimgs] = tomo_cal(stns,XfI,YfI,ZfI,OPS)
% tomo_cal - estimate calibration factor for fastprojection of 3D b-o-b
% 
% Calling:
%   [CalFactors,stns] = tomo_cal(stns,XfI,YfI,ZfI)
%
% See also TOMO_INP_CAMERA, CAMERA_SET_UP_SC, MAKE_TOMO_OPS
%

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

dOPS.disp3D = 0;
if nargin > 4
  dOPS = merge_structs(dOPS,OPS);
end


% 1 
Vem = 1e9*ones(size(XfI));
% 2 im = fastprojection(...
for i0 = 1:length(stns),
  
  stns(1).proj = fastprojection(Vem, ...
                                stns(1).uv, ...
                                stns(1).d, ...
                                stns(1).l_cl, ...
                                stns(1).bfk, ...
                                size(stns(1).img));
  % 3 
  [i1,i1,i2] = max2D(stns(i0).C);
  % 4 [az,ze,phi,theta] of im(i0,i2)
  [phi,theta] = camera_invmodel(i1,i2,v,stns(i0).optpar,stns(i0).optpar(9),size(stns(i0).img));
  % 4 
  l_int = (ZfI(1,1,end)-ZfI(1,1,1))*(size(ZfI,3)+1)/size(ZfI,3);
  % 5 Correct for cos(theta) & cos(phi)??
  % 5a nope, those corrections shouldn't be made.
  % 5b, well l_int should be made to be the total length, not only
  %     the height of the block of blobs!
  l_int = l_int/cos(theta);
  % 7 C_Rayleighs = im/l*DittenDatten, unit of size dimensions has to
  %   be taken into account. most common km!
  L_int(i0) = l_int;
  Theta(i0) = theta;
  ind1(i0) = i1;
  
end

