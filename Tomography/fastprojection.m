function img_out = fastprojection(Vem,uv,d,l_cl,bfk,imgsize,sens_mtr,sz3d)
% FASTPROJECTION - project the volume emission VEM down to image IMG_OUT.
% VEM is the 3D array that contins the volume emission
% distribution, UV is the projection matrix that projects the
% position of an element down to the image coordinates, D is the
% (distance dependent) scaling factor, L_CL is a cell-array holding
% indexes for 3D base functions in the corresponding
% size-class. BFK is the base-function-fotprint. SENS_MATR is an
% optional matrix for the pixel sensitivity.
% 
% Calling:
% img_out = fast_projection(Vem,uv,d,l_cl,bfk,sens_mtr)
%
% Based on the algorithm of Peter Rydesäter


%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(6,8,nargin));
if nargin > 7
  sz3din = size(Vem);
  if ~all(sz3din==sz3d)
    error('size of 3-D block-of-blobs does not match size of camera setup: %d %d %d (in) vs %d %d %d (set-up)',sz3din,sz3d)
  end
end

img_out = zeros(imgsize);
dimg = img_out;

for i1 = 1:length(l_cl),
  
  if min(size(l_cl{i1}))
    
    dimg(:) = uv(:,l_cl{i1})*(Vem(l_cl{i1})./d(l_cl{i1}).^2)';
    % 1./(d/ds^3/2)^2 == 1./(d^2/ds^(3/2*2)) == 1./(d^2/ds^(3)) == ds^3/d^2
    if issparse(dimg)
      dimg = full(dimg);
    end
    dimg = conv2(dimg,bfk{i1},'same');
    dimg = conv2(dimg,bfk{i1}','same');
    img_out = img_out + dimg;
    
  end
  
end

if ( nargin == 7 )
  
  img_out = img_out.*sens_mtr;
  
end
