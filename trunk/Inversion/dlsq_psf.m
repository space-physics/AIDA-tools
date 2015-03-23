function [rI,d,drI,fitHist] = dlsq_psf(U,S,V,I,p,epsilon_damp)
% DLSQ_PSF - Damped Least SQuare Point Spread Function calculation
% using the singular value decomposition of the forward matrix
% (U,S,V) to calculate the reconstruction of a point (or any
% general input pattern) A. The method will use damped LSQ if the
% optional input parameter EPSILON_DAMP is non-zero, and truncated
% if the optional input parameter p (integer) is smaller than the
% number of columns with non-zero eigenvalues in S.
%
% Calling:
%   [rI,d,dI,fitHist] = dlsq_psf(U,S,V,I,p,epsilon_damp)
% Input:
%  U - The USV matrices are supposed to be the singular value 
%  S - decomposition of the forward matrix M: [U,S,V] = svd(M);
%  V - Where M [n_data x n_model] where n_data is the number of
%      samples in the observations and n_model is the number of
%      unknowns to estimate.
%  I - input model source [n_data x 1]
%  p - truncation - number, index to smallest eigenvalue index to
%      use for the inversion. [1 x 1]
%  epsilon_damp - additional damping term - added to the
%                 eigenvalues before inverting the eigenvalue
%                 matrix. 
% Output:
%  rI - damped-truncated least square estimate of I
%  d  - artificial forward projection of I
%  rd - predicted observations rI would produce
%  fitHist - histogram of (d-rd)./max(1,rd)

%   Copyright � 20010805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%% Calculate the data that would be observed from model A
va = V'*I(:);    % 1: calculate V'*A 
usva = U*S*va;   % 2: and the remainder of the forward model: U*S*VA

if nargin > 4 && ~isempty(p)
  p = min(p,size(U,2));
else
  p = size(U,2);
end
if nargin > 5 && ~isempty(epsilon_damp)
  S2 = diag(diag(S)+epsilon_damp);
else
  S2 = diag(diag(S));
end

if nargout == 1
  [rI] = ftlsq_svd(U,S2,V,usva,p);
else
  [rI,fitHist,drI] = ftlsq_svd(U,S2,V,usva,p);
  d = usva;
end
