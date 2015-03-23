function [ra] = dlsq_svd(U,S,V,d)
% DLSQ_SVD damped least square solution to inverse problem using SVD matrices
% D = TRMTR*RA = [U*S*V]*RA where (U,S,V) is the sigular value
% decomposition od TRMTR. Using the singular value decomposition of
% the transfer matrix to calculate the reconstruction RA it is
% possible to use either damped LSQ or truncated LSQ. The method is
% damped if the EIGENVALUES in the diagonal matrix S are damped,
% and truncated if the matrices are truncated instead.
% 
% Calling:
% [ra] = dlsq_svd(U,S,V,d)
%

%   Copyright © 20041222 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

Upd = U'*d;
%iSUpd = inv(S)*Upd;
iSUpd = S\Upd;

ra = V*iSUpd;
