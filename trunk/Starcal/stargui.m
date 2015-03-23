% STARGUI - sets up the GUI for starcal
% Called once from within starcal, that is this script is called
% once per image to calibrate.
%

%   Copyright © 20011105 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% load saved optical parameters and identified stars
err = 0;
%param_file = [filename(1:3), '_', filename(4:16),'_param.mat'];
if ~isempty(filename)
  param_file = [filename(1:3), '_', filename(4:size(filename,2)-9), '_param.mat']
  param_file = genfilename(SkMp, 2)
  identstars = [];
else
  param_file = '';
  identstars = [];
end

if exist(param_file, 'file')
  answ = input('Load previously saved optical parameters and identified stars? (y/n)\n', 's');
  if isempty(answ)
    answ = 'y';
  end
  if answ == 'y'
    load(param_file);
    SkMp.param_load = 1;
    SkMp.slider_lock = 1;
    optpar 	= optpar_saved;
    optmod	= optmod_saved;
    identstars	= identstars_saved;
  end
end

SkMp.optpar = optpar;
SkMp.optmod = optmod;
SkMp.identstars = identstars;
SkMp.selectedstar = [0 0 0 0 0 0 0 0];
SkMp.img = cal_image;
SkMp = def_s_preferences(SkMp);

%Approximate old FOV.
%Make sure the fov angle is always positive by using abs()
if optmod==2
  SkMp.oldfov = 180/pi*asin(1/2/abs(optpar(2)))/optpar(8);
else
  SkMp.oldfov = 180/pi*atan(1/2/abs(optpar(2)));
end

[SkMp] = skymap(obs.longlat,obs.time,SkMp);

SkMp.optpar = optpar;
SkMp.optmod = optmod;
if optmod==2
  SkMp.oldfov = 180/pi*asin(1/2/abs(optpar(2)))/optpar(8);
else
  SkMp.oldfov = 180/pi*atan(1/2/abs(optpar(2)));
end

%if exist(param_file, 'file')
%	SkMp.slider_lock = 1;
%	[SkMp] = updstrpl(SkMp);
%	SkMp.slider_lock = 0;
%else

%[SkMp] = updstrpl(SkMp);

%end
figure(SkMp.figsky)
zoom on
colormap(bone)
set(SkMp.ui3(3),'Value',min(90,max(-90,optpar(3))));
set(SkMp.ui3(1),'Value',min(90,max(-90,-optpar(4))));
set(SkMp.ui3(4),'Value',max(0,abs(SkMp.oldfov)));
set(SkMp.ui3(4),'Value',max(0,abs(SkMp.oldfov)));
set(SkMp.ui3(2),'Value',min(90,max(-90,optpar(5))));
flipudlrstr = 'SkMp = updfliplrud(SkMp);';

SkMp.ui3(6) = uicontrol('Units','normalized',...
                        'Style','Popup',...
                        'String','Flip |l-r|u-d',...
                        'Position',[.91,.94,.075,.05],...
                        'Min',1,...
                        'Max',3,...
                        'Value',1,...
                        'Callback',flipudlrstr);
% Pup-up-menu for locking the sliders and only use optimized optpar:
SkMp.ui3(7) = uicontrol('Units','normalized',...
			'Style','togglebutton',...
			'String','SldrLck',...
			'Position',[.01,.01,.075,.05],...
			'Min',0,...
			'Max',1,...
			'Value',0,...
			'Callback','[SkMp] = updstrpl(SkMp);');

if ( version_nr > 5.1 )
  
  set(SkMp.ui3(7),'TooltipString','Lock sliders');
  set(SkMp.ui3(6),'TooltipString','Mirror star-field LR/UD');
  
end

% $$$ hidegui(SkMp.ui3(:),'callback')
set(SkMp.ui3(:),'handlevisibility','callback')

%SkMp.oldfov = 180/pi*atan(1/2/optpar(2));

SkMp.uic3(1,10) = uimenu(SkMp.uic3(1,6),...
			 'Label','Calibration/optim',...
			 'Callback','SkMp = s_preferences(SkMp,5);');
SkMp.uic3(1,11) = uimenu(SkMp.uic3(1,6),...
			 'Label','Zoom',...
			 'Callback','SkMp = s_preferences(SkMp,1);');

SkMp.uic3(5,1) = uimenu('Label','StarCal');
SkMp.uic3(5,2) = uimenu(SkMp.uic3(5,1),...
			'Label','Magnify',...
			'Callback','SkMp.currStarpoint = updzoom(SkMp);');

SkMp.uic3(5,3) = uimenu(SkMp.uic3(5,1), ...
			'Label','Identify', ...
			'Callback','[SkMp,starpar] = updfindstar(starpar,SkMp);');
SkMp.uic3(5,4) = uimenu(SkMp.uic3(5,1), ...
			'Label','Remove last identified star', ...
			'Callback','SkMp = upddellastr(SkMp);');
SkMp.uic3(5,11) = uimenu(SkMp.uic3(5,1), ...
			'Label','Select an identified star to be removed', ...
			'Callback','SkMp = updrmstar(SkMp);');
SkMp.uic3(5,5) = uimenu(SkMp.uic3(5,1), ...
			'Label','Plot id-stars', ...
			'Callback', ...
			'plot_stars_over');
SkMp.uic3(5,6) = uimenu(SkMp.uic3(5,1), ...
			'Label','Search optpar', ...
			'Callback','OptF_struct = updautomat(SkMp);');
SkMp.uic3(5,10) = uimenu(SkMp.uic3(5,1), ...
			 'Label','Revert optpar', ...
			 'Callback','SkMp = revert_optpar(SkMp);');
SkMp.uic3(5,7) = uimenu(SkMp.uic3(5,1), ...
			'Label','Save optpar', ...
			'Callback','saveacc(SkMp)');
SkMp.uic3(5,12) = uimenu(SkMp.uic3(5,1), ...
			'Label','Save preliminary optpar and star identification data', ...
			'Callback','saveoptident(SkMp)');
SkMp.uic3(5,8) = uimenu(SkMp.uic3(5,1), ...
			'Label','Semiautoidentify', ...
			'Callback','updautident');
SkMp.uic3(5,9) = uimenu(SkMp.uic3(5,1), ...
			'Label','Autocalibrate', ...
			'Callback','[SkMp,SkMp.identstars,SkMp.optpar] = trackemdown(SkMp);');

% $$$ hidegui(SkMp.uic3(5,:),'callback')
set(SkMp.uic3(5,:),'handlevisibility','callback')

SkMp.uic3(4,end+1) = uimenu(SkMp.uic3(4,1), ... 
			    'Label','Help calibration', ...
			    'Callback','starhelp(3)');
set(SkMp.uic3(4,2),'label','Help stars/sky')
SkMp.figzoom = figure('Name','zoom',...
		      'Position',[20,200,250,250],...
		      'Resize','on',...
		      'MenuBar','none');
SkMp.uic4(1,1) = uimenu('Label','Center');
SkMp.uic4(1,2) = uimenu(SkMp.uic4(1,1),...
			'Label','Center',...
			'Callback','updcenter2(SkMp);');

SkMp.uic4(2,1) = uimenu('Label','star');
SkMp.uic4(2,2) = uimenu(SkMp.uic4(2,1),...
			'Label','autopick',...
			'Callback','starpar = updstraut(SkMp);');
SkMp.uic4(2,3) = uimenu(SkMp.uic4(2,1),...
			'Label','man.pick',...
			'Callback','starpar = updstrman(SkMp);');

SkMp.uic4(3,1) = uimenu('Label',...
			'Help','Callback',...
			'starhelp(4)');
% $$$ hidegui(SkMp.uic4(:),'callback')
set(SkMp.uic4(:),'handlevisibility','callback')

if ~isfield(SkMp,'errorfig')
  
  SkMp = errorgui(SkMp);
  
end

if isfield(obs,'optpar')
  
  set(SkMp.ui3(1),'value',-obs.optpar(4)) % East-west
  set(SkMp.ui3(2),'value',obs.optpar(5))  % Rotation around optical axis
  set(SkMp.ui3(3),'value',obs.optpar(3))  % North-south
  set(SkMp.ui3(4),'value',abs(180/pi*atan(1/2/optpar(2)))) % field-of-view
  SkMp.found_optpar = 1;
  SkMp.slider_lock = 0;
  
end  

[SkMp] = updstrpl(SkMp);

set(SkMp.uic3(5,9),'enable','off')

if isfield(obs,'optpar')
  
  set(SkMp.ui3(1),'value',-obs.optpar(4)) % East-west
  set(SkMp.ui3(2),'value',obs.optpar(5))  % Rotation around optical axis
  set(SkMp.ui3(3),'value',obs.optpar(3))  % North-south
  set(SkMp.ui3(4),'value',abs(180/pi*atan(1/2/optpar(2)))) % field-of-view
  SkMp.found_optpar = 1;
  SkMp.slider_lock = 0;
  
end  
