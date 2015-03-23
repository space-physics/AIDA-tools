function [em_a,ex_a,ex_b,em_b] = V_em_ex_alt(I0_R0_DR,X,Y,Z,tau3D,T,fn)
% V_em_ex_alt, altitude, time variation of emission and excitation,
% along lines through center of emission and maximum emission
% 
% Calling:
%  [em_a,ex_a,ex_b,em_b] = V_em_ex_alt(I0_R0_DR,X,Y,Z,tau3D,T,fn)
% Input:
%  I0_R0_DR - 
%  X        - 
%  Y        - 
%  Z        - 
%  tau3D    - 
%  T        - 
%  fn       - 
% Output:
%  em_a - 
%  ex_a - 
%  ex_b - 
%  em_b - 


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

r0 = [-55.3533 149.7076 300];
e = [0 -sin(13*pi/180) cos(13*pi/180)];
z = 205:(329-205)/135:329;

for i1 = 2:(size(I0_R0_DR,1)-1),
  
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  Em(4*(i1-1)+1) = sum(V_em(:));
  Ex(4*(i1-1)+1) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  [qwe,Imaxi] = max(V_em(:));
  r_max = [X(Imaxi) Y(Imaxi) Z(Imaxi)];
  %keyboard
  r_em(4*(i1-1)+1,:) = em_r;
  r_ex(4*(i1-1)+1,:) = ex_r;
  
  r0_1 =  r_em(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  em_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  r0_1 =  r_ex(4*(i1-1)+1,:);
  if all(isfinite(r_max))
    r1 = point_on_line2(r_max',e',z-r_max(3));
  end
  em_b(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  
  Em(4*(i1-1)+2) = sum(V_em(:));
  Ex(4*(i1-1)+2) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  [qwe,Imaxi] = max(V_em(:));
  r_max = [X(Imaxi) Y(Imaxi) Z(Imaxi)];
  
  r_em(4*(i1-1)+2,:) = em_r;
  r_ex(4*(i1-1)+2,:) = ex_r;

  r0_1 =  r_em(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  em_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  r0_1 =  r_ex(4*(i1-1)+2,:);
  if all(isfinite(r_max))
    r1 = point_on_line2(r_max',e',z-r_max(3));
  end
  em_b(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  Em(4*(i1-1)+3) = sum(V_em(:));
  Ex(4*(i1-1)+3) = sum(dI3d(:));
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  [qwe,Imaxi] = max(V_em(:));
  r_max = [X(Imaxi) Y(Imaxi) Z(Imaxi)];
  
  r_em(4*(i1-1)+3,:) = em_r;
  r_ex(4*(i1-1)+3,:) = ex_r;

  r0_1 =  r_em(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  em_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  r0_1 =  r_ex(4*(i1-1)+3,:);
  if all(isfinite(r_max))
    r1 = point_on_line2(r_max',e',z-r_max(3));
  end
  em_b(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:));
  
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  Em(4*(i1-1)+4) = sum(V_em(:));
  Ex(4*(i1-1)+4) = sum(dI3d(:));
  
  ex_r = [sum(X(:).*dI3d(:)) sum(Y(:).*dI3d(:)) sum(Z(:).*dI3d(:))]/sum(dI3d(:));
  em_r = [sum(X(:).*V_em(:)) sum(Y(:).*V_em(:)) sum(Z(:).*V_em(:))]/sum(V_em(:));
  [qwe,Imaxi] = max(V_em(:));
  r_max = [X(Imaxi) Y(Imaxi) Z(Imaxi)];

  r_em(4*(i1-1)+4,:) = em_r;
  r_ex(4*(i1-1)+4,:) = ex_r;

  r0_1 =  r_em(4*(i1-1)+4,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  em_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  r0_1 =  r_ex(4*(i1-1)+4,:);
  if all(isfinite(r_max))
    r1 = point_on_line2(r_max',e',z-r_max(3));
  end
  em_b(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  if nargin == 7
    sstr = sprintf('save %s em_a ex_a ex_b',fn);
    eval(sstr)
  end
  
end
