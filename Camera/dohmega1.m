function [dohm] = dohmega1( epix, emib, f, omode, alfa )
% DOHMEGA1 is a function that calculates the solid
%          angle spanned by a pixel. EPIX is the 
%          line of sight unit vector of the pixel.
%          EMIB is the unit vector of the optical 
%          axis. F is the focal width in pixels, OMODE
%          is the optical transfer function number
%          and ALFA is an additional parameter for
%          optical transfer function #3.
%          
% Calling:
% [dohm] = dohmega1( epix, emib, f, omode, alfa )
% 
% Input: 
%  epix  - line-of-sight unit vectors for pixels
%  emib  - line-of-sight unit vector for optical axis.
%  f     - focal length (relative units)
%  omode - otical model number
%  alfa  - shape parameter
% 
%          See also DOHMEGA and  DOHMEGA2, CAMERA_MODEL


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(5,5,nargin))

if ( omode == 1 )
  
  a = epix*emib';
  dohm = (a*a*a/f/f);
  
elseif ( omode == 2 )
  
  dohm = (4/f/f);
  
elseif ( omode == 3 )
  
  a = epix*emib';
  b = acos(a);
  
  if ( b > 1e-13 )
    
    dohm = (1/f/f/((1-alfa)*(1-alfa)/(a*a*a)+alfa*(1-alfa)*b/a/a/sin(b)+alfa*(1-alfa)/a+alfa*alfa*b/sin(b)));
    
  else
    
    dohm = (1/f/f);
    
  end
  
end
