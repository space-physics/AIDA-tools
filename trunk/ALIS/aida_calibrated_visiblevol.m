function hndl = aida_calibrated_visiblevol(stn_pos,alt,optpar,edge,OPS)
% AIDA_CALIBRATED_VISIBLEVOL - Calculates the field of view from an ALIS   \  |  /
% station with a slightly simplified optical transfer                       \ | /
% function.                                                                  \|/
% 
% Calling:
% hndl = aida_calibrated_visiblevol(stnr,alt,optpar,edge,OPS);
% 
% Input:
%  STN_POS - Station positions [n_stn x 3] (east, north, altitude) (km)
%  ALT     - the altitude to plot the field of view on (km).
%  OPTPAR  - optical parameters of the cameras [n_stn x 9++] as
%            obtained from the star-calibration
%  EDGE    - flag for selecting (1) to plot the edges of the field
%            of view cone or not (0).
%  OPS     - options struct with field 'clrs' control the colour
%            used in plotting
% Output:
%  HNDL    - handle-graphics handle to field-of-view-lines

%   Copyright � 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 5,
  if nargin > 0 | nargout ~= 1
    help aida_calibrated_visiblevol;
  end
  hndl.clrs = {'b','c','g','m','r','y'};
  return;
end;


bxy = [512 512];


% q = [1 .7 0];
clrs = {'b','c','g','m','r','y'};
if nargin>=4 & isfield(OPS,'clrs')
  clrs = OPS.clrs;
end

for i1 = 1:size(stn_pos,1)
  
  hold on
  grid on
  
  % Pixel coordinates for image corners
  u = [1 512 512   1 1];
  v = [1   1 512 512 1];

  % Set the station position
  if nargin>=4 & isfield(OPS,'LL')
    r_stn(i1,:) = [0 0 0]; % For stn_pos in lat-long just set position to 0
  else
    r_stn(i1,:) = stn_pos(i1,:); % Else set to stn_pos (in km relative to some origin)
  end
  e_n = [0 0 1];
  % calculate spatial (cartesian) coordinates for corners
  % line-of-sigths at requested altitude
  [xx,yy,zz] = inv_project_points(u,v,zeros(bxy),r_stn(i1,:),optpar(i1,9),optpar(i1,:),e_n,alt(i1));
  
  if nargin>=4 & isfield(OPS,'LL')
    
    h0 = .245;
    
    if size(stn_pos,2) == 3
      % Convert postition from cartesian [x,y,z] to [lat,long,h]
      [r_stn(i1,1),r_stn(i1,2),r_stn(i1,3)] = xyz_2_llh(lat0,long0,h0,[stn_pos(i1,1),stn_pos(i1,1),.5]);
      % FIX-ME: get lat0, long0 some way...
    else
      r_stn(i1,1) = stn_pos(i1,1);
      r_stn(i1,2) = stn_pos(i1,2);
      r_stn(i1,3) = .5;
    end
    [xx(:),yy(:),zz(:)] = xyz_2_llh(r_stn(i1,1),r_stn(i1,2),h0,[xx(:),yy(:),zz(:)]);
    
% $$$   keyboard
    axis auto
  else
    axis('equal')
  end
  if nargin>=4 & isfield(OPS,'LL')
    
    phdl = plot3(stn_pos(i1,2),stn_pos(i1,1),1,'.');
    
  else
    r_stn(i1,3);
    phdl = plot3(r_stn(i1,1),r_stn(i1,2),r_stn(i1,3)+10,'.');
  end
  if clrs{i1} == 'y'
    set(phdl,'color',[.9 .6 0])
  else
    set(phdl,'color',clrs{i1})
  end
  
  set(phdl,'markersize',18)
  hndl{i1} = plot3(xx,yy,zz);
  
  if ( edge == 1 )
    
    for i2 = 1:4,
      hndl{i1}(1+i2) = plot3([r_stn(i1,1) xx(i2)],[r_stn(i1,2) yy(i2)],[r_stn(i1,3) zz(i2)]);
    end
    
  end
  
  if clrs{i1} == 'y'
    set(hndl{i1},'color',[.9 .6 0])
  else
    set(hndl{i1},'color',clrs{i1})
  end
  if ( alt(i1) < 60 )
  set(hndl{i1},'LineWidth',2);
  else
    set(hndl{i1},'LineWidth',1);
  end
  if nargin>4 & isfield(OPS,'linewidth')
    set(hndl{i1},'LineWidth',OPS.linewidth);
  end
  hndl{i1} = [hndl{i1},phdl];
  
end
