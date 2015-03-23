function hndl = aida_visiblevol(stn_pos,azim,zenit,alt,camfov,edge,OPS)
% AIDA_VISIBLEVOL - Calculates the field of view from an ALIS   \  |  /
% station with a slightly simplified optical transfer            \ | /
% function.                                                       \|/
% 
% Calling:
% hndl = aida_visiblevol(stn_pos,azim,zenit,alt,camfov,edge,OPS);
% 
% Input:
%  STN_POS - the station position either as Latitude-Longitude
%            (deg) pairs or as horizontal X,Y,Z (km) coordinates.
%  AZIM    - the azimuthal angle of the camera rotation in degrees.
%  ZENIT   - the zenith angle of the rotation, degrees.
%  ALT     - the altitude to plot the field of view on.
%  CAMFOV  - the camera field-of-view, side-to-side (degrees)
%  EDGE    - 1 for plotting the edges of the field of view cone
%  OPS     - options struct with field 'clrs' control the colour
%            used in plotting
% Output:
%  HNDL - handle-graphics handle to field-of-view lines

%   Copyright � 20050112 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 6,
  if nargin > 0 | nargout ~= 1
    help alis_visiblevol;
  end
  hndl.clrs = 'bcgmry';
  return;
end;


bxy = [512 512];


q = [1 .7 0];
clrs = {'b','c','g','m','r','y'};
if nargin>=7 & isfield(OPS,'clrs')
  clrs = OPS.clrs;
end

for i1 = 1:size(stn_pos,1)
  
  % convert azimuth and zenith angles to Tait-Bryant angles
  %raz = (-azim(i1)+90)*pi/180;
  raz = (azim(i1))*pi/180;
  rze = zenit(i1)*pi/180;
  % alfa and beta into degrees - going into guess_optpar...
  %beta = -180/pi * atan(cos(raz)/tan(rze));
  %alfa = -180/pi * asin(sin(raz)*sin(rze));
  beta = 180/pi * asin(cos(raz)*sin(rze));
% beta = 180/pi * asin(sin(raz)*sin(rze));
% alfa = 180/pi * atan(cos(raz)*tan(rze));
  alfa = 180/pi * atan2(sin(raz)*sin(rze),cos(rze));
  if isfield(OPS,'gamma_rot')
    gamma = OPS.gamma_rot(i1);
  else
    gamma = 0;
  end
  
  % Calculate focal length corresponding to field-of-view.
  f = 1/2/atan(pi/360*camfov(i1));
  guess_optp = [-f f alfa beta gamma 0 0 .3 3 1];
  
  hold on
  grid on
  
  % Pixel coordinates for image corners
  u = [1 512 512   1 1];
  v = [1   1 512 512 1];

  % Set the station position
  if nargin>=7 & isfield(OPS,'LL') & OPS.LL == 1 %  % correction bug CSW 201203
    r_stn(i1,:) = [0 0 0]; % For stn_pos in lat-long just set position to 0
  else
    r_stn(i1,:) = stn_pos(i1,:); % Else set to stn_pos (in km relative to some origin)
  end
  e_n = [0 0 1];
  % calculate spatial (cartesian) coordinates for corners
  % line-of-sigths at requested altitude
  [xx,yy,zz] = inv_project_points(u,v,zeros(bxy),r_stn(i1,:),guess_optp(9),guess_optp,e_n,alt(i1));
  %disp('zz (km)')
  %disp(zz)
  
  if nargin>=7 & isfield(OPS,'LL') & OPS.LL    %  % correction bug CSW 201203  
    h0 = .245;
    
    if size(stn_pos,2) == 3
      lat0 = stn_pos(1,1);
      long0 = stn_pos(1,2);
      % Convert postition from cartesian [x,y,z] to [lat,long,h]
      [r_stn(i1,1),r_stn(i1,2),r_stn(i1,3)] = xyz_2_llh(lat0,long0,h0,[stn_pos(i1,1),stn_pos(i1,2),.5]);
      % FIX-ME: get lat0, long0 some way...
    else
      r_stn(i1,1) = stn_pos(i1,1);
      r_stn(i1,2) = stn_pos(i1,2);
      r_stn(i1,3) = .5;
    end
    [xx(:),yy(:),zz(:)] = xyz_2_llh(r_stn(i1,1),r_stn(i1,2),h0,[xx(:),yy(:),zz(:)]);
    axis auto
  else
    axis('equal')
  end
  if nargin>=7 & isfield(OPS,'LL') & OPS.LL == 1 %  % correction bug CSW 201203
    
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
  if nargin>6 & isfield(OPS,'linewidth')
    set(hndl{i1},'LineWidth',OPS.linewidth);
  end
  hndl{i1} = [hndl{i1},phdl];
  
end
