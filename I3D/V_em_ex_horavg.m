function [em_a,ex_a] = V_em_ex_horavg(I0_R0_DR,X,Y,Z,tau3D,T,fn)
% V_em_ex_horavg - horisontal averages of altitude-time variation
% of volume emission rate and excitation rate
% 
% Calling:
%   [em_a,ex_a] = V_em_ex_horavg(I0_R0_DR,X,Y,Z,tau3D,T,fn)

%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

r0 = [-55.3533 149.7076 300];
e = [0 -sin(13*pi/180) cos(13*pi/180)];
z = 205:(329-205)/135:329;

for i1 = 2:(size(I0_R0_DR,1)-1),
  %disp(i)
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
			      T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  
  em_a(4*(i1-1)+1,:) = sum(sum(V_em,1),2);
  ex_a(4*(i1-1)+1,:) = sum(sum(dI3d,1),2);
  
  
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
			      T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  
  em_a(4*(i1-1)+2,:) = sum(sum(V_em,1),2);
  ex_a(4*(i1-1)+2,:) = sum(sum(dI3d,1),2);
  
  
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
			      T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;

  em_a(4*(i1-1)+3,:) = sum(sum(V_em,1),2);
  ex_a(4*(i1-1)+3,:) = sum(sum(dI3d,1),2);
  
  
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI_3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I_3d_p_dI3D_multiple(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
			      T(1:i1),tau3D,V_em,dI3d);
  %ii = find(~isfinite(dI3d(:)));
  %dI3d(ii) = 0;
  dI3d(~isfinite(dI3d(:))) = 0;
  %ii = find(~isfinite(V_em(:)));
  %V_em(ii) = 0;
  V_em(~isfinite(V_em(:))) = 0;
  
  em_a(4*(i1-1)+4,:) = sum(sum(V_em,1),2);
  ex_a(4*(i1-1)+4,:) = sum(sum(dI3d,1),2);
  
  if nargin == 7
    sstr = sprintf('save %s em_a ex_a',fn);
    eval(sstr)
  end
  
end
