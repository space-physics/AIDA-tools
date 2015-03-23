function H = bquiver(x,y,dx,dy,l,s)
% BQUIVER is a temporary interface to the function ARROW() that is 
%         currently unavailable for matlab 5.0. ARROWB draws arrows
%         from the points specified by (x,y) to (x+vx,y+vy) in the 
%         colour c.
%
% Calling:
% H = bquiver(x,y,dx,dy,l,s)

%   Copyright ©  1997 by Bjorn Gustavsson <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

error(nargchk(6,6,nargin));

%%%out = arrow([x,y],[x+dx*l,y+dy*l],'facecolor',s,'edgecolor',s);
H=arrow3([x,y],[x+dx*l,y+dy*l],s);
%set(H,'color',s);
