function e_rand = rand_direction(n_vecs,n_dims)
% RAND_DIRECTION - unit vectors pointing in random directions
%   
% Calling:
%  e_rand = rand_direction(n_vecs,n_dims)
% Input:
%  n_vecs - number of unit vectors
%  n_dims - number dimensions
% Example:
%  e_3D = rand_direction(45,3);
%  e_2D = rand_direction(54,2);
% ...to create 45 unit vectors pointing in random directions in 3-D
% and 54 in 2-D

% Copyright B Gustavsson 20080416

e_rand = randn(n_vecs,n_dims);
for i1 = 1:size(e_rand,1),
  
  e_rand(i1,:) = e_rand(i1,:)/norm(e_rand(i1,:));
  
end
