function [ra,hvals,rd] = ftlsq_svd(U,S,V,d,I)
% FTLSQ_SVD filtered truncated least square from SVD decomposition
% Uses singular decomposition of transfer matrix to calculate
% reconstructions of RA from D with truncations at Ith eigenvalue.
% 
% Calling:
%  [ra,hvals] = ftlsq_svd(U,S,V,d,I)


%   Copyright © 20050805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

hvals = [];
j1 = 1;
for i1 = I,
  
  %Upd = U(:,1:i1)'*d;
  %iSUpd = inv(S(1:i1,1:i1))*Upd;
  ra = U(:,1:i1)'*d;
  %ra = inv(S(1:i1,1:i1))*ra;
  ra = S(1:i1,1:i1)\ra;
  ra = V(:,1:i1)*ra;
  if nargout > 1 
    rd = V(:,1:i1)'*ra;
    rd = S(1:i1,1:i1)*rd;
    rd = U(:,1:i1)*rd;
    nbins = ceil(sqrt(length(d)));
    hvals(j1,:) = hist((d-rd)./max(rd,1),nbins);
    j1 = j1+1;
  end
end
