function [dohm] = dohmega2( theta , optpar, omode, alpha )
% DOHMEGA2 - calculate the solid angle spanned by a pixel.
%          
% Calling:
% [dohm] = dohmega2( theta , f, omode, alpha )
% 
% INPUT:
%  THETA is the polar angle relative to the optical axis,
%  OPTPAR is the optical parameter,
%  OMODE  is the optical transfer function number and 
%  ALFA is an additional parameter. 
% 
%          See also DOHMEGA and  DOHMEGA2


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(4,4,nargin))
fu = optpar(1);
fv = optpar(2);
alpha = optpar(8);
% £££ f = optpar(1);
% £££ du = optpar(6);
% £££ dv = optpar(7);

if ( omode == 1 )
  
  dohm = (cos(theta).^3/fu/fv);
  
elseif ( omode == 2 )
  % u^2+v^2 = f*sin(theta/2)
  %dohm = (4/f/f)*ones(size(theta));
  % replaced with u^2+v^2 = f*sin(theta*alpha)
  dohm = (1/alpha/fu/fv)*sin(theta)./cos(alpha*theta)./sin(alpha*theta);
  dohm(theta(:)<1e-13) = (1/fu/fv/alpha);
  
elseif ( omode == 3 )
  
  %a = cos(theta);
  %b = theta;
  
  dohm = sin(theta)./(-1+alpha*tan(theta).^2-tan(theta).^2)./(-tan(theta)*alpha+ alpha*theta+tan(theta))/fu/fv;
  dohm(theta(:) < 1e-13) = (1/fu/fv);
  
elseif ( omode == 4 )
  % r = f*theta^alpha
  dohm = sin(theta)./theta.^(2*alpha-1)/alpha/fu/fv;
  dohm(theta(:) < 1e-13) = (1/fu/fv);
elseif ( omode == 5 )
  % u^2+v^2 = f*tan( alpha*theta/2 )
  dohm = (1/alpha/fu/fv)*sin(theta).*cos(alpha*theta).^3./sin(alpha*theta);
  dohm(theta(:)<1e-13) = (1/fu/fv/alpha.^2);
  
end
dohm = abs(dohm);
