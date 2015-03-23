function [pm1,X,Y,Z,mtb3t] = ALIS_make_projmatr(dr1,dr2,dr3,sx,sy,sz,optpar,rllc,ap)
% ALIS_MAKE_PROJMATR - make projection matrix for ALIS camera,
% obsolete


%   Copyright © 2000 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

aurora = ones([sx,sy,sz]);

[X,Y,Z] = r0dr_2_XYZ(aurora,rllc,dr1,dr2,dr3);

bild1 = zeros([256 17]);

[pm1] = bildb_sp_matr(1,optpar,aurora,bild1,rllc,dr1,dr2,dr3,5577,ap);

mtb3t = zeros(size(bild1));
mtb3t(:) = pm1*aurora(:);
