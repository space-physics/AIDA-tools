function h = tomo_slice_i(X,Y,Z,V,ix,iy,iz)
% TOMO_SLICE_I - slice with arbitrary X, Y, and Z,
%  the generalized slices is taken at row/column/layer indices.
%
% Calling:
%  h = tomo_slice_i(X,Y,Z,V,ix,iy,iz)
% Input:
%  X - x-coordinate of 3-D grid; sized (n1,n2,n3) double
%  Y - y-coordinate of 3-D grid; sized (n1,n2,n3) double
%  Z - z-coordinate of 3-D grid; sized (n1,n2,n3) double
%  V - volume distribution; sized (n1,n2,n3) double
%  ix - indices to make cuts for in x-direction [1 x n], integer
%  iy - indices to make cuts for in y-direction [1 x n], integer
%  iz - indices to make cuts for in z-direction [1 x n], integer
% Output:
%  h - handle graphics handle to the displayed cuts,



%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

is_hold = ishold;
if ~is_hold
  hold on
end

H = [];
for i1 = 1:length(ix),
  
  H(end+1) = surf(squeeze(X(:,ix(i1),:)),...
                  squeeze(Y(:,ix(i1),:)),...
                  squeeze(Z(:,ix(i1),:)),...
                  squeeze(V(:,ix(i1),:)));
  
end
for i1 = 1:length(iy),
  
  H(end+1) = surf(squeeze(X(iy(i1),:,:)),...
                  squeeze(Y(iy(i1),:,:)),...
                  squeeze(Z(iy(i1),:,:)),...
                  squeeze(V(iy(i1),:,:)));
  
end
for i1 = 1:length(iz),
  
  H(end+1) = surf((X(:,:,iz(i1))),...
                  (Y(:,:,iz(i1))),...
                  (Z(:,:,iz(i1))),...
                  (V(:,:,iz(i1))));
  
end
shading interp
view(-37.5,30)% Seems to be the default matlab view for slice
if ~is_hold
  hold off
end
if nargout
  h = H;
end
