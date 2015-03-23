function [Em,Ex,I_ex,I_em,r_em,r_ex,exm] = V_em_ex_intrp(I0_R0_DR,X,Y,Z,tau3D,T)
% V_em_ex_intrp - total emission, excitation, widths of excitation
% and emission, center of excitation and emission.
%
% Calling:
%  [Em,Ex,I_ex,I_em,r_em,r_ex,exm] = V_em_ex_intrp(I0_R0_DR,X,Y,Z,tau3D,T)

%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

for i1 = 2:size(I0_R0_DR,1),
  
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
		     T(1:i1),tau3D,V_em,dI3d);
  Em(4*(i1-1)+1) = sum(V_em(:));
  Ex(4*(i1-1)+1) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i1-1)+1,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+1,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+1,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+1,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+1,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i1-1)+1,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i1-1)+1,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+1,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+1,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+1,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+1,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i1-1)+1,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i1-1)+1,:) = em_r;
  r_ex(4*(i1-1)+1,:) = ex_r;
  exm(4*(i1-1)+1) = max(dI3d(:));
  
  
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
		     T(1:i1),tau3D,V_em,dI3d);
  %nani = find(isnan(V_em(:)));
  %V_em(nani) = 0;
  V_em(isnan(V_em(:))) = 0;
  
  Em(4*(i1-1)+2) = sum(V_em(:));
  Ex(4*(i1-1)+2) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i1-1)+2,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+2,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+2,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+2,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+2,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i1-1)+2,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i1-1)+2,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+2,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+2,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+2,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+2,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i1-1)+2,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i1-1)+2,:) = em_r;
  r_ex(4*(i1-1)+2,:) = ex_r;
  exm(4*(i1-1)+2) = max(dI3d(:));
  
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
		     T(1:i1),tau3D,V_em,dI3d);
  Em(4*(i1-1)+3) = sum(V_em(:));
  Ex(4*(i1-1)+3) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i1-1)+3,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+3,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+3,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+3,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+3,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i1-1)+3,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i1-1)+3,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+3,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+3,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+3,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+3,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i1-1)+3,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i1-1)+3,:) = em_r;
  r_ex(4*(i1-1)+3,:) = ex_r;
  exm(4*(i1-1)+3) = max(dI3d(:));
  
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
		     T(1:i1),tau3D,V_em,dI3d);
  Em(4*(i1-1)+4) = sum(V_em(:));
  Ex(4*(i1-1)+4) = sum(dI3d(:));
  
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i1-1)+4,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+4,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i1-1)+4,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+4,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i1-1)+4,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i1-1)+4,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i1-1)+4,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+4,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i1-1)+4,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+4,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i1-1)+4,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i1-1)+4,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i1-1)+4,:) = em_r;
  r_ex(4*(i1-1)+4,:) = ex_r;
  exm(4*(i1-1)+4) = max(dI3d(:));
  
end
