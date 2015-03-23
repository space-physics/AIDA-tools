function [uv,d,l_cl,bfk,ds,sz3d] = camera_set_up_sc(r,xi,yi,zi,optpar,robs,imgsize,nr_layers,cmtr,ds)
% CAMERA_SET_UP_SC - Calculates the projection matrix from 3-D simple cubic grid 
% to image coordinates the distance from the grid points to the
% camera position and it also divides the 3D grid into size clases
% and give indices to the base functions in each size class as well
% as the corresponding base-function-footproints. R is the 3D
% position of the grid-points. XI, YI and ZI is 3-D index arrays of
% the grid-points. OPTPAR are the optical parameters of the camera
% OPTPAR(3:5) is the camera rotation angles in degrees - see
% CAMERA_ROT. ROBS are the 3-D coordinate of the
% camera-position. IMGSIZE is the image-size [sx sy]. NR_LAYERS are
% the number of size-classes the 3-D grid is divided into.
% 
% Calling:
% [uv,d,l_cl,bfk,ds,sz3d] = camera_set_up_sc(r,xi,yi,zi,optpar,robs,imgsize,nr_layers)
%
% See also FASTPROJECTION, CAMERA_SET_UP_FCC

%   Copyright � 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Should be depreciated and removed, but I'll keep it for this
% release too:
global bxy bx by
% Get the image dimensions:
bxy = imgsize;
bx = bxy(2);
by = bxy(1);

% And the dimensions of the 3-D block-o-blobbs:
sx = size(xi,2);
sy = size(xi,1);
sz = size(xi,3);
sz3d = size(xi);

% Scale the volume emission rates with the volume of the base-functions:
if nargin < 10
  ds = 1;
end

% Calculate the image projections of the base-function-centroids:
if nargin > 8
  [u,v,d] = project_point(robs,optpar,r,cmtr,bxy);
else
  [u,v,d] = project_point(robs,optpar,r,[],bxy);
end
% U is the horizontal image position, V is the vertical, and D is
% the distance to the base-function centroid.

% Calculate the image sizes of the base-functions
vs = max(min(sc_sizing(u,v,size(xi)),max(imgsize)),1);

% Here we fix for voxels outside the camera field-of-view
notinimgindx = find(u<1|u>imgsize(1)|v<1|v>imgsize(2)|~isfinite(u)|~isfinite(v));
% Just set the image point to the [1,1] corner pixel:
u(notinimgindx) = 1;
v(notinimgindx) = 1;
% And throw the base-functions away to infinity:
d(notinimgindx) = inf;
% d(notinimgindx) makes sure that the projections to [u,v] = 1,1 do not
% contribute to the projected image.
% $$$ why is this stuff done twice?

% Divide the base-functions into NR_LAYERS number of layers:
[l_cl,cl_sz] = sc_grouping(vs,nr_layers);
% Create the corresponding number of 1-D base-function
% shapes/filter-kernels:
bfk = base_fcn_kernel(ceil(cl_sz));
bfk{nr_layers+1} = 0;   % set the "spread filter" for the final layer to zero as these blobs do not project to the image
 
% u(notinimgindx) = 1;
% v(notinimgindx) = 1;
% d(notinimgindx) = inf;


% Create the sparse projection matrix M for projecting the
% base-function centroids to the image plane (I_centroids = UV*I3D(:);): 
uv =      sparse( ceil(v(:)) + (ceil(u(:)) - 1 ) * by, ...
		  yi(:) + sy * (xi(:)-1) + sx * sy * (zi(:)-1), ...
		 ( v(:) - floor(v(:)) + ( v(:) == floor(v(:)) ) ) .* ( u(:) - floor(u(:)) + (u(:) == floor(u(:)) ) ), ...
		 prod(bxy),numel(xi(:)));

uv = uv + sparse( floor(v(:)) + (ceil(u(:))-1) * by, ...
		  yi(:) + sy * (xi(:)-1) + sx * sy * (zi(:)-1), ...
		 ( ceil(v(:)) - v(:)) .* (u(:) - floor(u(:)) + ( u(:) == floor(u(:)) ) ), ...
		 prod(bxy),numel(xi(:)));

uv = uv + sparse(ceil(v(:))+(floor(u(:))-1)*by, ...
		 yi(:)+sy*(xi(:)-1)+sx*sy*(zi(:)-1), ... 
		 (v(:)-floor(v(:))+(v(:)==floor(v(:)))).*(ceil(u(:))-u(:)), ...
		 prod(bxy),numel(xi(:)));

uv = uv + sparse(floor(v(:))+(floor(u(:))-1)*by, ... 
		 yi(:)+sy*(xi(:)-1)+sx*sy*(zi(:)-1), ...
		 (ceil(v(:))-v(:)).*(ceil(u(:))-u(:)), ...
		 prod(bxy),numel(xi(:)));

% Scale d:
d = d / ds^(3/2);
% That way the product I3D(:)./d.^2 becomes I3D(:)./d^2*ds^3
