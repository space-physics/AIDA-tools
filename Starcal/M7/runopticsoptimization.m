function [optpar,SkMp] = runopticsoptimization(SkMp,OptF_struct,varargin)
% RUNOPTICSOPTIMIZATION - does the fitting of optical paramameters
% 
% Calling:
%   [optpar,SkMp] = runopticsoptimization(SkMp,OptF_struct,varargin)

%   Copyright © 1997 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin > 2
  batch = varargin{1};
else
  batch = 0;
end

ui7 = OptF_struct.ui7;
ui7a = OptF_struct.ui7a;
identstars = SkMp.identstars;
figoptp = OptF_struct.figopt;
startpar(3) = str2num(get(ui7(1),'String'));
startpar(4) = str2num(get(ui7(2),'String'));
startpar(5) = str2num(get(ui7(3),'String'));
startpar(1) = str2num(get(ui7(4),'String'));
startpar(2) = str2num(get(ui7(5),'String'));
startpar(6) = str2num(get(ui7(6),'String'));
startpar(7) = str2num(get(ui7(7),'String'));
startpar(8) = str2num(get(ui7(12),'String'));


locked_par(3) = get(ui7a(1),'value');
locked_par(4) = get(ui7a(2),'value');
locked_par(5) = get(ui7a(3),'value');
locked_par(1) = get(ui7a(4),'value');
locked_par(2) = get(ui7a(5),'value');
locked_par(6) = get(ui7a(6),'value');
locked_par(7) = get(ui7a(7),'value');
locked_par(8) = get(ui7a(12),'value');

mode = get(ui7(8),'Value');

if mode == 7
  mode = -1;
end
if mode == 8
  mode = -2;
end
if mode == 9
  mode = 11;
end

set(figoptp,'pointer','watch')
set(SkMp.figsky,'pointer','watch')

% For the non-parametric optical transfer functions either ignore
% (-1) previous camera rotation estimates or use them (-2). In the
% first case just set the unit vectors to something unrotated.
if mode == -1
  optpar.rot = [0 0 0];
elseif mode == -2
  try
    optpar.rot = SkMp.optpar(3:5);
  catch
    optpar.rot = SkMp.optpar.rot;
  end
end

if mode < 0
  
  % Non-parametric optical model based on fiting of smooth surfaces
  % of the observed [az,ze]-[u,v] (both directions). The actual
  % fiting is done with gridfit.
  
  % Get the unit vectors for the assumed camera rotation
  [e1,e2,e3] = camera_base(optpar.rot(1),optpar.rot(2),optpar.rot(3));
  
  % Extract the azimuth and zenith angles of the identified stars
  az = SkMp.identstars(:,1);
  ze = SkMp.identstars(:,2);
  % and calculate the corresponding line-of-sight vectors
  es1 = sin(ze).*sin(az);
  es2 = sin(ze).*cos(az);
  es3 = cos(ze);
  % Projection of l-o-s vector in direction [az,ze] onto e1
  dot_e_e1 = es1*e1(1) + es2*e1(2) + es3*e1(3);
  % Projection of l-o-s vector in direction [az,ze] onto e2
  dot_e_e2 = es1*e2(1) + es2*e2(2) + es3*e2(3);
  % Projection of l-o-s vector in direction [az,ze] onto e3
  dot_e_e3 = es1*e3(1) + es2*e3(2) + es3*e3(3);
  
  u  = SkMp.identstars(:,3)/size(SkMp.img,2);
  v  = SkMp.identstars(:,4)/size(SkMp.img,1);
  % Coordinates for interpolation in the horisontal components of
  % pixel lines-of-sights (no plural-s on of)
  cosazsinze_i = linspace(-1,1,50); % cos*sin is confined to the
  sinazsinze_i = linspace(-1,1,50); % interval [-1 1]
  
  % ...och en uppskattning av projectionen fraan [u,v] till
  % horisontella komponenterna:
  % [sin(ze)*cos(az),sin(ze)*cos(az)] till [u,v]
  
  % Coordinates for interpolation in the image coordinates
  u_i = linspace(0,1,50); % u och v are constrained to the
  v_i = linspace(0,1,50); % interval [0 1]
  
  % Start with a "large" smoothness factor which should give
  % smoother surfaces, which will lead to larger spread between
  % actual stellar position in image and projected. Then reduce as
  % needed.
  smoothness_factor = (3/2)^8;
  err_too_large = 1;
  max_iter = 10;
  nr_iter = 0;
  while err_too_large && nr_iter < max_iter
    nr_iter = nr_iter +1;
    % Do approximate projections from
    %% [sin(ze)*cos(az),sin(ze)*cos(az)] to [u,v]
    %optpar.u = gridfit(dot_e_e1,dot_e_e2,u,cosazsinze_i,sinazsinze_i,'smooth',smoothness_factor);
    %optpar.v = gridfit(dot_e_e1,dot_e_e2,v,cosazsinze_i,sinazsinze_i,'smooth',smoothness_factor);
    %
    %%% The above was questionable: since we have az clock-wise from
    % north it is likely to be better the other way around:
    % [sin(ze)*sin(az),sin(ze)*cos(az)] to [u,v]
    optpar.u = gridfit(dot_e_e1,dot_e_e2,u,sinazsinze_i,cosazsinze_i,'smooth',smoothness_factor);
    optpar.v = gridfit(dot_e_e1,dot_e_e2,v,sinazsinze_i,cosazsinze_i,'smooth',smoothness_factor);
    
    % ...and from [u,v] to the components of the line-of-sight
    % vectors
    % Inte cosazsinze, sinazsinze utan dot_e_e1, dot_e_e2, dot_e_e3!
    optpar.sinzesinaz = gridfit(u,v,dot_e_e1,u_i,v_i,'smooth',smoothness_factor);
    optpar.sinzecosaz = gridfit(u,v,dot_e_e2,u_i,v_i,'smooth',smoothness_factor);
    optpar.cosze      = min(1,gridfit(u,v,dot_e_e3,u_i,v_i,'smooth',smoothness_factor));
    
    % Check the fit of the projections by comparing the spread of
    % the projection from [u,v]->[sin(ze)*cos(az),sin(ze)*cos(az)]
    sinzecosaz = interp2(u_i,v_i,optpar.sinzecosaz,u,v); % se till att faa en  vektor ut!
    sinzesinaz = interp2(u_i,v_i,optpar.sinzesinaz,u,v);
    % ...and back [sin(ze)*cos(az),sin(ze)*cos(az)]->[u_a,v_a].
    u_m = interp2(sinazsinze_i,cosazsinze_i,optpar.u,dot_e_e1,dot_e_e2);
    v_m = interp2(sinazsinze_i,cosazsinze_i,optpar.v,dot_e_e1,dot_e_e2);
    
    % This is done by measuring the std of the difference between
    % observed image position [u,v] and the projected-projected
    % approximation [u_a,v_a]:
    % max(std(u-u_a),std(v-v_a)) which should be less than
    % "something_statistically_motivated" (\pm 1/5 pixels)
    cax = caxis;
    figure(SkMp.figsky)
    hold on
    plot(u_m*size(SkMp.img,2),v_m*size(SkMp.img,1),'g.')
    
    imgs_smart_caxis(0.001,SkMp.img(:))
    pause(1)
    unplot
    
    err = max(std((u-u_m)*size(SkMp.img,2)),std((v-v_m)*size(SkMp.img,1)))
    something_statistically_motivated = 1/2;
    if err < something_statistically_motivated
      err_too_large = 0;
    else
      
      smoothness_factor = smoothness_factor*2/3;
      
    end
    
  end
  optpar.mod = mode;
  if ~isfield(SkMp,'errorfig')
    
    SkMp = errorgui(SkMp);
    
  end
else
  
  sp2 = startpar;
  
  optpar = fminsearch(@(startpar) automat2(startpar,identstars,mode,sp2,locked_par,size(SkMp.img)),startpar);
  
  if length(SkMp.optpar) > 9
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5),SkMp.optpar(10));
  else
    [e1,e2,e3] = camera_base(SkMp.optpar(3),SkMp.optpar(4),SkMp.optpar(5));
  end
  set(SkMp.ui3(4),'value',180/pi*atan(1/2/mean(abs(optpar(1:2)))));
  set(SkMp.ui3(3),'value',optpar(3));
  set(SkMp.ui3(1),'value',-optpar(4));
  set(SkMp.ui3(2),'value',optpar(5));
  SkMp.oldfov  = 180/pi*atan(1/2/mean(abs(optpar(1:2))));
  SkMp.oldaz0  = optpar(3);
  SkMp.oldze0  = -optpar(4);
  SkMp.oldrot0 = optpar(5);
  
end

SkMp.e1 = e1;
SkMp.e2 = e2;
SkMp.e3 = e3;

[u,w] = project_directions(identstars(:,1)',identstars(:,2)',optpar,mode,size(SkMp.img));
SkMp.uapr = u';
SkMp.vapr = w';
SkMp.previous_optpar = SkMp.optpar;
SkMp.previous_optmod = SkMp.optmod;
SkMp.optpar = optpar;
SkMp.optmod = mode;

SkMp.found_optpar = 1;
SkMp.slider_lock = 1;

set(SkMp.ui3(7), 'Value', 1);
	
if batch ~= 1
	close(figoptp)
	set(SkMp.figsky,'pointer','arrow')
	starplot(SkMp.plottstars,SkMp);
end
