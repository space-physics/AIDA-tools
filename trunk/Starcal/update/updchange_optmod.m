function SkMp = updchange_optmod(SkMp,OptF_struct)
% UPDCHANGE_OPTMOD - rescales focal widths and the alpha distortion parameter
%   to give the radial projection function the same slope for small
%   angles to the optical axis. That is:
% 
%    ( (u-u0)^2 + (v-v0)^2 )/( (u'-u0)^2 + (v'-v0)^2 ) = 1,
%  for small thete. Here 
%   [u,v] = f*g(theta,alpha)*[cos(phi),sin(phi)]+[u0,v0]
%  and
%   [u',v'] = f'*g'(theta,alpha')*[cos(phi),sin(phi)]+[u0,v0]
%  Here "'" means \prime, not matlab-transpose
%
%  This functin is called when changing optical transfer function
%  in the figure for "setting optical parameters and starting the
%  search for optical parameters".

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


optmod_new = get(OptF_struct.ui7(8),'Value');


current_optmod = SkMp.optmod;
  
switch optmod_new
 case 1 % u = f*tan(theta)
  set(OptF_struct.ui7(8),'value',1)
  alpha_new = 1;
 case 2 % u = f*sin(alpha*theta)
  set(OptF_struct.ui7(8),'value',2)
  alpha_new = 0.75;
 case 3 % u = f*( (1-alpha)*tan(theta) + alpha*theta )
  set(OptF_struct.ui7(8),'value',3)
  alpha_new = 0.35;
 case 4 % u = f*(theta)
  set(OptF_struct.ui7(8),'value',4)
  alpha_new = 1;
 case 5 % u = f*tan(alpha*theta)
  set(OptF_struct.ui7(8),'value',5)
  alpha_new = 0.75;
 otherwise % If the optical model is not one of the 1 to 5 then the
           % optpar rescaling is unknown/pointless - so just bolt
           % from here and do no dammage...
  return
end


oldMod = current_optmod;
if isfield(SkMp,'optpar')
  optpar = optparOld2optparNew(SkMp.optpar,alpha_new,oldMod,optmod_new);
end

SkMp.current_optmod = optmod_new;
SkMp.optmod = optmod_new;
SkMp.optpar = optpar;

set(OptF_struct.ui7(4),'String',num2str(optpar(1)));
set(OptF_struct.ui7(5),'String',num2str(optpar(2)));
set(OptF_struct.ui7(12),'String',num2str(optpar(8)));

% $$$ function optpar = optpOld2optpNew(optpar,alpha_new,oldMod,newMod)
% $$$ % OPTPOLD2OPTPNEW - 
% $$$ %   
% $$$ 
% $$$ n_old = [0,1,0,0,1];
% $$$ n_new = [0,1,0,0,1];
% $$$ 
% $$$ [oldMod,newMod, optpar(8).^n_old(oldMod), alpha_new^n_new(newMod),  optpar(8).^n_old(oldMod)/alpha_new^n_new(newMod)]
% $$$ optpar(1:2) = optpar(1:2)*optpar(8).^n_old(oldMod)/alpha_new^n_new(newMod);
% $$$ optpar(8) = alpha_new;
