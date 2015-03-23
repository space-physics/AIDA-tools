function CC = corr(V1,V2)
% CORR_COEF_CMT - raw correlation between multidim V1 and V2
%   
% Calling:
% CC = corr_coef_cmt(V1,V2)
% 
% Input:
%   V1 and V2 should be of same dimensions
% Output: 
%   CC correrlation coefficient

% Copyright © Bjorn Gustavsson 20050110, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


CC = corrcoef(V1(:),V2(:));
CC = CC(1,2);
