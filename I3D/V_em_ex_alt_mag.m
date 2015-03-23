function [em_a,ex_a] = V_em_ex_alt_mag(I0_R0_DR,X,Y,Z,tau3D,T)
% V_em_ex_alt_mag - altitude distribution of emission and
% excitation along a fixed line. Extremely stypid function, with
% hard-coded coordinates for the line...
%
% Calling:
% [em_a,ex_a] = V_em_ex_alt_mag(I0_R0_DR,X,Y,Z,tau3D,T)


%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

%r0 = [-55.3533 149.7076 300];
r0 = [-46.9969  196.2742   -3.1939];
e = [0 -sin(13*pi/180) cos(13*pi/180)];

z = 180:(329-205)/135:329;

for i1 = 2:(size(I0_R0_DR,1)-1),
  disp(i1)
  %25 %
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
  r_ex(4*(i1-1)+1,:) = [-46.9969  196.2742   -3.1939];

  %r0_1 =  r_ex(4*(i-1)+1,:);
  r0_1 =  r0;%r_ex(4*(i-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  %50 %
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %nani = find(isnan(V_em(:)));
  %V_em(nani) = 0;
  V_em(isnan(V_em(:))) = 0;
  
  r_ex(4*(i1-1)+1,:) = [-46.9969  196.2742   -3.1939];
  
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  %75 %
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
  r_ex(4*(i1-1)+1,:) = [-46.9969  196.2742   -3.1939];
  
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  %100 %
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
  r_ex(4*(i1-1)+1,:) = [-46.9969  196.2742   -3.1939];
  
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
end
