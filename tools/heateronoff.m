function h = heateronoff(level,hon,hoff,delta_level)
% HEATERONOFF - plottin heater on periods 
% 
% Calling:
%   h = heateronoff(LEVEL,HON,HOFF)
% Input:
%   LEVEL - the y-level for the heater-on marks, 
%   HON - the x-start-position for heater-on marks
%   HOFF - the x-stop-position for heater-on marks
% Output:
%   H - handle to the line objects ploted

% Copyright © 2008 Bjorn Gustavsson <bjorn.gustavsson@irf.se>, 
%   This is free software, licensed under GNU GPL version 2 or later


hold on

if ( nargin < 3 )
  
  hon = 32:4:82;
  hon = [hon, 84:8:152];
  hoff = 34:4:82;       
  hoff = [hoff, 88:8:152];
  % hon = hon;
  % hoff = hoff;
  ph = plot([hon hoff]/60+16,[level level],'k','linewidth',8);
  
elseif nargin < 4
  
  if length(level)==1
    level = level*ones(size(hon));
  end
  for i1 = length(hon):-1:1,
    
    ph(i1) = plot([hon(i1) hoff(i1)],[level(i1) level(i1)],'k','linewidth',8);
    
  end
  
elseif nargin == 4
  
  if length(level)==1
    level = level*ones(size(hon));
  end
  for i1 = length(hon):-1:1,
    
    ph(i1) = fill([hon(i1) hoff(i1) hoff(i1) hon(i1)],level(i1)+delta_level/2*[-1,-1,1,1],'k');
    
  end
  
end

if nargout > 0
  
  h = ph;
  
end
