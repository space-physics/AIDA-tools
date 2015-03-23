function [ra,hvals] = pdlsq_svd(U,S,V,d,I,imgshape)
% PDLSQ_SVD filtered damped/truncated least square from SVD decomposition
% Uses singular decomposition of transfer matrix to calculate
% reconstructions of RA from D with truncations at Ith eigenvalue.
% Presents reconstruction and error histograms for each I
% 
% Calling:
%  [ra,hvals] = pdlsq_svd(U,S,V,d,I,imgshape)


%   Copyright © 20050805 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Find first eigenvalue smaller than 1

%TBR?: ds = diag(S);
%TBR?: pI = find(ds<1);
% $$$ pI = 
hvals = zeros(length(I),19);
j1 = 1;
for i1 = I,
  
  %Upd = U(:,1:i1)'*d;
  %iSUpd = inv(S(1:i1,1:i1))*Upd;
  ra = U(:,1:i1)'*d;
  %ra = inv(S(1:i1,1:i1))*ra;
  ra = S(1:i1,1:i1)\ra;
  
  ra = V(:,1:i1)*ra;
  rd = V'*ra;
  rd = S*rd;
  rd = U*rd;
  %[hv,hh] = hist_test(d,rd);
  [hv,hh] = statt(d,rd);
  %whos
  hvals(j1,:) = hv;
  j1 = j1+1;
  subplot(1,2,1)
  bar(hh),title(num2str(i1)),xlabel(num2str(hv))
  subplot(1,2,2)
  imagesc(reshape(ra,imgshape)),axis xy
  drawnow
  pause(1)
end
