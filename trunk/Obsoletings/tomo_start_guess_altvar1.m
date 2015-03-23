function [Vem,stns] = tomo_start_guess_altvar1(Par,stns,XfI,YfI,ZfI,tomo_ops,OPS)
% TOMO_START_GUESS_ALTVAR1 - 3D start guess with varying alt and width
%   
% Calling:
%   err = tomo_start_guess_altvar1(Par,stns,XfI,YfI,ZfI,tomo_ops,OPS)
%
% Will require that ZfI is horizontally layered


%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

disp('You''re calling tomo_start_guess_altvar1 from:')
dbstack
disp('I stronlgy suggest that you switch to use: tomo_err4sliceGACT')

h = squeeze(ZfI(1,1,:));

if isfield(stns(1).obs,'trmtr')
  cmt = stns(1).obs.trmtr;
else
  cmt = eye(3);
end
% Current vertical altitude distribution of volume emission rates:
for i3 = 1:size(Par,1)
  
  hmax = Par(i3,1);
  w0 = Par(i3,2);
  [I_of_h] = chapman(1,hmax,w0,h);
  [Imax,i_zmax] = max(I_of_h);
  
  % Horisontal 0-th distribution
  Imp_H = inv_project_img_surf(stns(1).img,...
                               stns(1).r,stns(1).optpar(9),...
                               stns(1).optpar,...
                               XfI(:,:,i_zmax),YfI(:,:,i_zmax),ZfI(:,:,i_zmax),...
                               cmt);
  
  Imp_Hmax = nanmax(Imp_H(:));
  Imp_H(Imp_H(:)<0) = nan;
  if ~all(isfinite(Imp_H))
    Imp_H = min(Imp_Hmax,exp(inpaint_nans(log(Imp_H))));
  end
  Vem = zeros(size(XfI));
  for i1 = 1:size(Imp_H,1),
    for i2 = 1:size(Imp_H,2),
      Vem(i1,i2,:) = Imp_H(i1,i2)*I_of_h;
    end
  end
  [stns,Vem] = adjust_level(stns,Vem,1);
  
  err(i3) = 0;
  for i1 = 2:length(stns)
    rn = tomo_ops(i1).renorm;
    qb = tomo_ops(i1).qb;
    % Scale the projections - make us just use the shape of things...
    stns(i1).proj = ( stns(i1).proj * ...
                      sum(sum(stns(i1).img(rn(3):rn(4),rn(1):rn(2))))/...
                      sum(sum(stns(i1).proj(rn(3):rn(4),rn(1):rn(2)))));
    
    err1 = sum(sum(( stns(i1).img( qb(3):qb(4),qb(1):qb(2)) - ...
                     stns(i1).proj(qb(3):qb(4),qb(1):qb(2)) ).^2 ));
    err(i3) = err(i3) + err1;
    
  end
end

[min_err,i_best] = min(err);

hmax = Par(i_best,1);
w0 = Par(i_best,2);
[I_of_h] = chapman(1,hmax,w0,h);
% Horisontal 0-th distribution
Imp_H = inv_project_img_surf(stns(1).img,...
                             stns(1).r,stns(1).optpar(9),...
                             stns(1).optpar,...
                             XfI(:,:,i_zmax),YfI(:,:,i_zmax),ZfI(:,:,i_zmax),...
                             cmt);
Imp_Hmax = nanmax(Imp_H(:));
Imp_H(Imp_H(:)<0) = nan;
if ~all(isfinite(Imp_H))
  Imp_H = min(Imp_Hmax,exp(inpaint_nans(log(Imp_H))));
end
for i1 = 1:size(Imp_H,1),
  for i2 = 1:size(Imp_H,2),
    Vem(i1,i2,:) = Imp_H(i1,i2)*I_of_h;
  end
end
[stns,Vem] = adjust_level(stns,Vem,1);
