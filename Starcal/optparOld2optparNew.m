function optpar = optparOld2optparNew(optpar,alpha_new,oldMod,newMod)
% OPTPAROLD2OPTARPNEW - scale f_u and f_v between optical transfer functions
%   Given an array with optical parameters for an optical transfer
%   function:
%    [u,v] = g(theta,alpha)*[f_u*cos(phi),f_v*sin(phi)]+[u0,v0]
%   one might have to scale the focal widths (f_u, f_v) if one
%   changes the OTF from g() to g'(). OPTPAROLD2OPTARPNEW rescales
%   focal widths and the alpha distortion parameter to give the
%   radial projection function the same slope for small angles to
%   the optical axis. That is:
% 
%    ( (u-u0)^2 + (v-v0)^2 )/( (u'-u0)^2 + (v'-v0)^2 ) = 1,
%  for small thete. Here 
%   [u,v] = f*g(theta,alpha)*[cos(phi),sin(phi)]+[u0,v0]
%  and
%   [u',v'] = f'*g'(theta,alpha')*[cos(phi),sin(phi)]+[u0,v0]
%  Here "'" means \prime, not matlab-transpose
%
% Calling:
%   optpar = optparOld2optparNew(optpar,alpha_new,oldMod,newMod)
% Input:
%   optpar    - array with optical parameters
%   alpha_new - distortion parameter alpha as in
%               f*tan(alpha*theta), f*sin(alpha*theta)
%   oldMod    - current optical transfer function number
%   newMod    - new optical transfer function number
%               1 - f*tan(theta)
%               2 - f*sin(alpha*theta)
%               3 - f*( (1-alpha)*tan(theta) + alpha*theta
%               4 - f*theta
%               5 - f*tan(alpha*theta)

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

n_old = [0,1,0,0,1];
n_new = [0,1,0,0,1];

%  [oldMod,newMod, optpar(8).^n_old(oldMod), alpha_new^n_new(newMod),  optpar(8).^n_old(oldMod)/alpha_new^n_new(newMod)]
optpar(1:2) = optpar(1:2)*optpar(8).^n_old(oldMod)/alpha_new^n_new(newMod);
optpar(8) = alpha_new;
