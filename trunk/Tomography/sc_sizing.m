function [vs] = sc_sizing(u,v,vsize)
% SC_SIZING - calculates the approximate size in the image plane
% of the projection of base functions in a simple-cubic grid
% U and V are the image coordinates of the 3-D grid. VSIZE are the
% size of the original 3-D grid.
% 
% Calling:
% [vs] = sc_sizing(u,v,vsize)


%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

u3 = reshape(u,vsize);
v3 = reshape(v,vsize);

[v1,v2,v3] = gradient(v3);
[u1,u2,u3] = gradient(u3);
% Check this!!!
%------------------------------------------------------|
%                Seems to work just right!             |
%                                                      V
vs = max(abs([u1(:),u2(:),u3(:),v1(:),v2(:),v3(:)]'))*2^.5;
%vs = max(abs([u1(:),u2(:),u3(:),v1(:),v2(:),v3(:)]'))*2^.5;
%Mu12 = max([abs(u1(:)),abs(u2(:))],[],2);
%Mu3v1 = max([abs(u3(:)),abs(v1(:))],[],2);
%Mv23 = max([abs(v2(:)),abs(v3(:))],[],2);
%vs = max([Mu12,Mu3v1,Mv23]')*2^.5;

