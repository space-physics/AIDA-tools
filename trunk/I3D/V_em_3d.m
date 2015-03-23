function [V_em] = V_em_3d(I0_R0_DR,X,Y,Z,tau3D,T)
% V_em_3d calculate volume emission rates by C-EQ integration with interpolated-parameters
%
% Calling:
%  [V_em] = V_em_3d(I0_R0_DR,X,Y,Z,tau3D,T)
% 
% See also: dI3D_multiple, I3d_p_dI3D


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

for i1 = 2:size(I0_R0_DR,1),
  
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
                    T(1:i1),tau3D,V_em,dI3d);

  
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %nani = find(isnan(V_em(:)));
  %V_em(nani) = 0;
  V_em(isnan(V_em(:))) = 0;
  
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
end
