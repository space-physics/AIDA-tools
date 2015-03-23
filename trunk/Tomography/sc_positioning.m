function [r,xi,yi,zi] = sc_positioning(r0,dr1,dr2,dr3,Vem)
% SC_POSITIONING - position voxels/base-functions in SC grid. 
% R0 - lower left corner   
% DR1,DR2,DR3 - Base vectors along the sides of the voxel block.
% VEM - The 3-D block of voxels
% 
% Calling:
% function r = sc_positioning(r0,dr1,dr2,dr3,Vem)
%


%   Copyright © 20010305 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

sx = size(Vem,2);
sy = size(Vem,1);
sz = size(Vem,3);

[xi,yi,zi] = meshgrid(1:sx,1:sy,1:sz);

r = dr1'*(xi(:)'-1)+dr2'*(yi(:)-1)'+dr3'*(zi(:)'-1);

r(1,:) = r(1,:)+r0(1);
r(2,:) = r(2,:)+r0(2);
r(3,:) = r(3,:)+r0(3);
