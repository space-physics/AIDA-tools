function [f] = tlsq_svd(U,S,V,d,lambda_cutoff)
% tlsq_svd - Truncated least square solution to linear inverse problem.
%  
% Calling:
%   [f] = dlsq_svd(U,S,V,d,lambda_cutoff)
% Input:
%   U,S,V - SVD decomposition matrices, see SVD
%   d     - right hand side, data vector d = A*f
% Optional:
%   lambda_cutoff - truncation level for singular values, the
%   solution will be built with all singular values (and
%   corresponding eigen-vectors) larger than lambda_cutoff. Default
%   is 1.


%   Copyright � 20080701 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 5 || isempty(lambda_cutoff)
  lambda_cutoff = 1;
end
i_cut = sum(diag(S)>=lambda_cutoff);
Ut_d = U(:,1:i_cut)'*d;
iS_Ut_d = S(1:i_cut,1:i_cut)\Ut_d;

f = V(:,1:i_cut)*iS_Ut_d;
