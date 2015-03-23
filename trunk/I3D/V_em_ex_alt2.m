function [em_h,ex_h] = V_em_ex_alt2(I0_R0_DR,X,Y,Z,tau3D,T,fn)
% V_em_ex_alt2 - time variation of altitude distribution of emission and excitation
% 
% Calling:
% [em_h,ex_h] = V_em_ex_alt2(I0_R0_DR,X,Y,Z,tau3D,T,fn)



%   Copyright © 2002 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

V_em = zeros(size(X));

%r0 = [-55.3533 149.7076 300];
r0 = [-55.3533 157.7076 250];
e = [0 -sin(13*pi/180) cos(13*pi/180)];
z = 205:(329-205)/135:329;

for i1 = 2:(size(I0_R0_DR,1)-1),
  disp(i1)
  Iintrp = I0_R0_DR(i1,:)*.25+I0_R0_DR(i1-1,:)*.75;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1) T(i1)+2.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  
  % point 1
  r_ex(4*(i1-1)+1,:) = [-55 162 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 2
  r_ex(4*(i1-1)+1,:) = [-60 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_b(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 3
  r_ex(4*(i1-1)+1,:) = [-55 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_c(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_c(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 4
  r_ex(4*(i1-1)+1,:) = [-50 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_d(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_d(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 5
  r_ex(4*(i1-1)+1,:) = [-55 152 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_e(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_e(4*(i1-1)+1,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  em_h(4*(i1-1)+1,:) = em_a(4*(i1-1)+1,:) + ...
                       em_b(4*(i1-1)+1,:) + ...
                       em_c(4*(i1-1)+1,:) + ...
                       em_d(4*(i1-1)+1,:) + ...
                       em_e(4*(i1-1)+1,:);
  ex_h(4*(i1-1)+1,:) = ex_a(4*(i1-1)+1,:) + ...
                       ex_b(4*(i1-1)+1,:) + ...
                       ex_c(4*(i1-1)+1,:) + ...
                       ex_d(4*(i1-1)+1,:) + ...
                       ex_e(4*(i1-1)+1,:);
  
  Iintrp = I0_R0_DR(i1,:)*.5+I0_R0_DR(i1-1,:)*.5;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+2.5 T(i1)+5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  %nani = find(isnan(V_em(:)));
  %V_em(nani) = 0;
  V_em(isnan(V_em(:))) = 0;
  
  % point 1
  r_ex(4*(i1-1)+2,:) = [-55 162 237];
  
  r0_1 =  r_ex(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 2
  r_ex(4*(i1-1)+2,:) = [-60 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_b(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 3
  r_ex(4*(i1-1)+2,:) = [-55 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_c(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_c(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 4
  r_ex(4*(i1-1)+2,:) = [-50 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_d(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_d(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 5
  r_ex(4*(i1-1)+2,:) = [-55 152 237];
  
  r0_1 =  r_ex(4*(i1-1)+2,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_e(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_e(4*(i1-1)+2,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  em_h(4*(i1-1)+2,:) = em_a(4*(i1-1)+2,:) + ...
                       em_b(4*(i1-1)+2,:) + ...
                       em_c(4*(i1-1)+2,:) + ...
                       em_d(4*(i1-1)+2,:) + ...
                       em_e(4*(i1-1)+2,:);
  ex_h(4*(i1-1)+2,:) = ex_a(4*(i1-1)+2,:) + ...
                       ex_b(4*(i1-1)+2,:) + ...
                       ex_c(4*(i1-1)+2,:) + ...
                       ex_d(4*(i1-1)+2,:) + ...
                       ex_e(4*(i1-1)+2,:);
  
  Iintrp = I0_R0_DR(i1,:)*.75+I0_R0_DR(i1-1,:)*.25;
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+5 T(i1)+7.5], ...
                    T(1:i1),tau3D,V_em,dI3d);
  % point 1
  r_ex(4*(i1-1)+3,:) = [-55 162 237];
  
  r0_1 =  r_ex(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 2
  r_ex(4*(i1-1)+3,:) = [-60 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_b(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 3
  r_ex(4*(i1-1)+3,:) = [-55 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_c(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_c(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 4
  r_ex(4*(i1-1)+3,:) = [-50 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_d(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_d(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 5
  r_ex(4*(i1-1)+3,:) = [-55 152 237];
  
  r0_1 =  r_ex(4*(i1-1)+3,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_e(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_e(4*(i1-1)+3,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  em_h(4*(i1-1)+3,:) = em_a(4*(i1-1)+3,:) + ...
                       em_b(4*(i1-1)+3,:) + ...
                       em_c(4*(i1-1)+3,:) + ...
                       em_d(4*(i1-1)+3,:) + ...
                       em_e(4*(i1-1)+3,:);
  ex_h(4*(i1-1)+3,:) = ex_a(4*(i1-1)+3,:) + ...
                       ex_b(4*(i1-1)+3,:) + ...
                       ex_c(4*(i1-1)+3,:) + ...
                       ex_d(4*(i1-1)+3,:) + ...
                       ex_e(4*(i1-1)+3,:);
  
  Iintrp = I0_R0_DR(i1,:);
  dI3d = dI3D_multiple(Iintrp,X,Y,Z,2.5,tau3D);
  V_em = I3d_p_dI3D(Iintrp,X,Y,Z,I0_R0_DR(1:i1-1,:),[T(i1)+7.5 T(i1+1)], ...
                    T(1:i1),tau3D,V_em,dI3d);
  % point 1
  r_ex(4*(i1-1)+4,:) = [-55 162 237];
  
  r0_1 =  r_ex(4*(i1-1)+4,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_a(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 2
  r_ex(4*(i1-1)+4,:) = [-60 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+4,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_b(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_b(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 3
  r_ex(4*(i1-1)+4,:) = [-55 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+4,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_c(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_c(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 4
  r_ex(4*(i1-1)+4,:) = [-50 157 237];
  
  r0_1 =  r_ex(4*(i1-1)+4,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_d(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_d(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  
  % point 5
  r_ex(4*(i1-1)+4,:) = [-55 152 237];
  
  r0_1 =  r_ex(4*(i1-1)+1,:);
  r1 = point_on_line2(r0_1',e',z-r0_1(3));
  
  em_e(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(V_em,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  ex_e(4*(i1-1)+4,:) = interp3(Y,X,Z,permute(dI3d,[2 1 3]),r1(2,:),r1(1,:),r1(3,:),'cubic');
  em_h(4*(i1-1)+4,:) = em_a(4*(i1-1)+4,:) + ...
                       em_b(4*(i1-1)+4,:) + ...
                       em_c(4*(i1-1)+4,:) + ...
                       em_d(4*(i1-1)+4,:) + ...
                       em_e(4*(i1-1)+4,:);
  ex_h(4*(i1-1)+4,:) = ex_a(4*(i1-1)+4,:) + ...
                       ex_b(4*(i1-1)+4,:) + ...
                       ex_c(4*(i1-1)+4,:) + ...
                       ex_d(4*(i1-1)+4,:) + ...
                       ex_e(4*(i1-1)+4,:);
  
  if ( nargin == 7 )
    sstr = sprintf('save %s em_a ex_a ex_b z',fn);
    eval(sstr)
  end
  
end
