function [img_moments] = img_moments(pm1,pm2,pm3,I0_R0_DR,X,Y,Z,tau3D,T)
% Unfinished: img_moments


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

for i = 2:size(I0_R0_DR,1),
  
  I0_r0_dr = real(I0_r0_dr);


  Iintrp = I0_r0_dr*.25+I0_R0_DR(end,:)*.75;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR,[T(end) T(end)+2.5],T,tau,V_em,dI3d);
  
  Iintrp = I0_r0_dr*.5+I0_R0_DR(end,:)*.5;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR,[T(end)+2.5 T(end)+5],T,tau,V_em,dI3d);
  V_em_exp = V_em;
  
  Iintrp = I0_r0_dr*.75+I0_R0_DR(end,:)*.25;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR,[T(end)+5 T(end)+7.5],T,tau,V_em,dI3d);
  V_em_exp = V_em_exp + 4*V_em;
  Iintrp = I0_r0_dr;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau);
  
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR,[T(end)+7.5 t],T,tau,V_em,dI3d);
  V_em_exp = 5/6*(V_em_exp + V_em);
  b_p1 = zeros([128 128]);
  b_p1(:) = pm1*V_em_exp(:);
  b_p2 = zeros([128 128]);
  b_p2(:) = pm2*V_em_exp(:);
  b_p3 = zeros([128 128]);
  b_p3(:) = pm3*V_em_exp(:);

  
  
  Iintrp = I0_R0_DR(i,:)*.25+I0_R0_DR(i-1,:)*.75;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i-1,:),[T(i) T(i)+2.5], ...
		     T(1:i),tau3D,V_em,dI3d);
  Em(4*(i-1)+1) = sum(V_em(:));
  Ex(4*(i-1)+1) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i-1)+1,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+1,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+1,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+1,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+1,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i-1)+1,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i-1)+1,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+1,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+1,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i-1)+1,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i-1)+1,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i-1)+1,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i-1)+1,:) = em_r;
  r_ex(4*(i-1)+1,:) = ex_r;
  exm(4*(i-1)+1) = max(dI3d(:));
  
  
  Iintrp = I0_R0_DR(i,:)*.5+I0_R0_DR(i-1,:)*.5;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i-1,:),[T(i)+2.5 T(i)+5], ...
		     T(1:i),tau3D,V_em,dI3d);
  %nani = find(isnan(V_em(:)));
  %V_em(nani) = 0;
  V_em(isnan(V_em(:))) = 0;
  Em(4*(i-1)+2) = sum(V_em(:));
  Ex(4*(i-1)+2) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i-1)+2,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+2,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+2,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+2,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+2,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i-1)+2,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i-1)+2,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+2,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+2,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i-1)+2,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i-1)+2,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i-1)+2,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i-1)+2,:) = em_r;
  r_ex(4*(i-1)+2,:) = ex_r;
  exm(4*(i-1)+2) = max(dI3d(:));
  
  Iintrp = I0_R0_DR(i,:)*.75+I0_R0_DR(i-1,:)*.25;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i-1,:),[T(i)+5 T(i)+7.5], ...
		     T(1:i),tau3D,V_em,dI3d);
  Em(4*(i-1)+3) = sum(V_em(:));
  Ex(4*(i-1)+3) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i-1)+3,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+3,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+3,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+3,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+3,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i-1)+3,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i-1)+3,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+3,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+3,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i-1)+3,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i-1)+3,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i-1)+3,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i-1)+3,:) = em_r;
  r_ex(4*(i-1)+3,:) = ex_r;
  exm(4*(i-1)+3) = max(dI3d(:));
  
  Iintrp = I0_R0_DR(i,:);
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i-1,:),[T(i)+7.5 T(i+1)], ...
		     T(1:i),tau3D,V_em,dI3d);
  Em(4*(i-1)+4) = sum(V_em(:));
  Ex(4*(i-1)+4) = sum(dI3d(:));
  
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  I_ex(4*(i-1)+4,1) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+4,2) = sum(dI3d(:).*((X(:)-ex_r(1)).^2+(Z(:)-ex_r(3)).^2));
  I_ex(4*(i-1)+4,3) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2+(X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+4,4) = sum(dI3d(:).*((X(:)-ex_r(1)).^2));
  I_ex(4*(i-1)+4,5) = sum(dI3d(:).*((Y(:)-ex_r(2)).^2));
  I_ex(4*(i-1)+4,6) = sum(dI3d(:).*((Z(:)-ex_r(3)).^2));
  
  I_em(4*(i-1)+4,1) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+4,2) = sum(V_em(:).*((X(:)-em_r(1)).^2+(Z(:)-em_r(3)).^2));
  I_em(4*(i-1)+4,3) = sum(V_em(:).*((Y(:)-em_r(2)).^2+(X(:)-em_r(1)).^2));
  I_em(4*(i-1)+4,4) = sum(V_em(:).*((X(:)-em_r(1)).^2));
  I_em(4*(i-1)+4,5) = sum(V_em(:).*((Y(:)-em_r(2)).^2));
  I_em(4*(i-1)+4,6) = sum(V_em(:).*((Z(:)-em_r(3)).^2));
  r_em(4*(i-1)+4,:) = em_r;
  r_ex(4*(i-1)+4,:) = ex_r;
  exm(4*(i-1)+4) = max(dI3d(:));
  
end
