function [pstarsout,uk,wk] = starsinimg(pstars,optpar,optmod, imsiz)
% STARSINIMG is a function that finds stars inside the image field-of-view.
% Used in the starcalibration program.
% 
% Calling:
% [pstarsout,uk,wk] = starsinimg(pstars,optpar,optmod)

%   Copyright © 2011 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


global bx by

if optmod < 0
  
  [e1,e2,e3] = camera_base(optpar.rot(1),optpar.rot(2),optpar.rot(3));
  
else
  
  alpha0 = optpar(3);
  beta0 = optpar(4);
  gamma0 = optpar(5);
  if length(optpar) > 9
    [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,optpar(10));
  else
    [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
  end
% $$$   az0 = optpar(3);
% $$$   el0 = optpar(4);
% $$$   roll = optpar(5);
% $$$   
% $$$   [e1,e2,e3] = camera_base(az0,el0,roll);
  
end
Nrstj = size(pstars);

% tdiff = 0;

indx = 1;

for i1 = 1:Nrstj(1),
  
  az = pstars(i1,1);
  ze = pstars(i1,2);
  [u,w] = camera_model(az,ze,e1,e2,e3,optpar,optmod, imsiz);
  if ( inimage(u,w,bx,by))
    
    uk(indx) = u;
    wk(indx) = w;
    pstarsout(indx,:) = pstars(i1,:);
    indx = indx + 1;
    
  end
  
end
