function [dohm] = dohmega( a1,a2,a3,a4,a5 )
% DOHMEGA - calculate the solid angle spanned by a pixel.
%         
% Calling:
% [dohm] = dohmega( a1,a2,a3,a4,a5 )
% 
% What a help!
%         See DOHMEGA1 and  DOHMEGA2


%   Copyright © 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(4,5,nargin))

if ( 4 == nargin )
  
  dohm = dohmega2( a1, a2, a3, a4 );
  
else
  
  dohm = dohmega1( a1, a2, a3, a4, a5 );
  
end
