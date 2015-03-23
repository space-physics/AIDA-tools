function err = ba_rt_error(Par,stns,OPS,XfI,YfI,ZfI,rstns,tomo_ops)
% BA_RT_ERROR - Black aurora inversion error function
%   
% Calling:
%  err = ba_rt_error(Par,stns,OPS,XfI,YfI,ZfI,rstns) 



%   Copyright © 2006 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Current vertical altitude distribution of volume emission rates:
%[I_of_h] = chapman(I0,hmax,w0,h);
[I_of_h,z_max_I,i_zmax] = auroral_I_altEdep([1 Par],squeeze(ZfI(1,1,:)),OPS);
I_of_h = (I_of_h/max(I_of_h));
% Horisontal 0-th distribution
Imp_R = inv_project_img_surf(stns(1).img,...
                             rstns(1,:),stns(1).optpar(9),...
                             stns(1).optpar,...
                             XfI(:,:,i_zmax),YfI(:,:,i_zmax),ZfI(:,:,i_zmax),eye(3));
Imp_D = inv_project_img_surf(stns(2).img,...
                             rstns(2,:),stns(1).optpar(9),...
                             stns(2).optpar,...
                             XfI(:,:,i_zmax),YfI(:,:,i_zmax),ZfI(:,:,i_zmax),eye(3));
Imp_R(~isfinite(Imp_R)) = .1;
for i1 = size(Imp_R,1):-1:1,
  for i2 = size(Imp_R,2):-1:1,
    if isfinite(Imp_D(i1,i2))
      I2D(i1,i2) = (Imp_R(i1,i2)/max(Imp_R(:))+Imp_D(i1,i2)/max(Imp_D(:)))/2;
    else
      I2D(i1,i2) = Imp_R(i1,i2)/max(Imp_R(:));
    end
    Vem(i1,i2,:) = I2D(i1,i2)*I_of_h;
  end
end
[stns,Vem] = adjust_level(stns,Vem,1);
[Vem,stns] = tomo_steps(Vem,stns,tomo_ops,6);
rn1 = tomo_ops.renorm(1,:);
rn2 = tomo_ops.renorm(2,:);
qb1 = tomo_ops.qb(1,:);
qb2 = tomo_ops.qb(2,:);
% Scale the projections - make us just use the shape of things...
stns(2).proj = ( stns(2).proj * ...
                    sum(sum(stns(2).img(rn2(3):rn2(4),rn2(1):rn2(2))))/...
                    sum(sum(stns(2).proj(rn2(3):rn2(4),rn2(1):rn2(2)))));
stns(1).proj = ( stns(1).proj * ...
                    sum(sum(stns(1).img(rn1(3):rn1(4),rn1(1):rn1(2))))/...
                    sum(sum(stns(1).proj(rn1(3):rn1(4),rn1(1):rn1(2)))));

err2 = sum(sum(( stns(2).img(qb2(3):qb2(4),qb2(1):qb2(2)) - ...
                 stns(2).proj(qb2(3):qb2(4),qb2(1):qb2(2)) ).^2 ));
err1 = sum(sum(( stns(1).img(qb1(3):qb1(4),qb1(1):qb1(2)) - ...
                 stns(1).proj(qb1(3):qb1(4),qb1(1):qb1(2)) ).^2 ));
err = err1 + err2;
