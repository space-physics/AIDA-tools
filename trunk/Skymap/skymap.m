function [SkMp] = skymap(pos,time,SkMp)
% SKYMAP An easy to astronomical starchart.
% It sets up a graphiczal user ingerface for the
% skymap and an input figure for selection of observation sites,
% date and time. 
%
% Calling:
%   SkMp = skymap(pos,time,SkMp);
%


%   Copyright � 20010401 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global stardir
verstr = version;
version_nr = str2num(verstr(1:3));


stardir = fileparts(which('skymap'));

checkokstr = '[stnnames,SkMp] = checkok(SkMp);';
updstrplstr = '[SkMp] = updstrpl(SkMp);';
str0 =  ['SkMp.radecl_or_azze = 0;',updstrplstr];
str1 = ['SkMp.radecl_or_azze = 1;',updstrplstr];

SkMp.set_up_file = fullfile(stardir,'set_up_file.dat');
SkMp.radecl_or_azze = 1;
if nargin < 3
  SkMp.optpar = [];
  SkMp.img = [];
  SkMp.identstars = [];
end

[long,lat,alts,StnNames,stnNR] = station_reader;
% $$$ Cannot completely remove Pelle and Kalle, can I?
% $$$ Nope, They'll remain as characters in this script for as long as I live!
% $$$ load(fullfile(stardir,'Stations','stationpos.dat'))
% $$$ pelle = stationpos(:,4).*(stationpos(:,1) + stationpos(:,2)/60 + stationpos(:,3)/3600);
% $$$ if abs(stationpos(:,8)) == 1
% $$$   kalle = stationpos(:,8).*(stationpos(:,5) + stationpos(:,6)/60 + stationpos(:,7)/3600);
% $$$ else
% $$$   kalle = (stationpos(:,5) + stationpos(:,6)/60 + stationpos(:,7)/3600);
% $$$ end
% $$$ stationpos = [kalle,pelle];
SkMp.stationpos = [long,lat];
SkMp.longlat = [long,lat];
SkMp.StnNames = StnNames;
SkMp.stnNR = stnNR;
SkMp.figchok = [];

if ~isfield(SkMp,'prefs')
   SkMp = def_s_preferences(SkMp);
end

try 
  Mon_Pos = get(0,'MonitorPositions');
catch
  Mon_Pos = [0 0 700 700];
end

SkMp.figsky = figure('Name','Skyview',...
		     'Position',[Mon_Pos(3)-600,Mon_Pos(4)-600,540,530],...
		     'Resize','on',...
		     'MenuBar','none');

figure(SkMp.figsky);
% The slider on the left edge
SkMp.ui3(1) = uicontrol('Units','normalized',...
			'Style','Slider',...
			'Position',[.01,.1,.03,.8],...
			'Min',-90,...
			'Max',90,...
			'Value',0,...
			'Callback',updstrplstr);
% The slider on the right edge
SkMp.ui3(2) = uicontrol('Units','normalized',...
			'Style','Slider',...
			'Position',[.96,.1,.03,.8],...
			'Min',-180,...
			'Max',180,...
			'Value',0,...
			'Callback',updstrplstr);
% The slider on the lower edge
SkMp.ui3(3) = uicontrol('Units','normalized',...
			'Style','Slider',...
			'Position',[.1,.01,.8,.03],...
			'Min',-90,...
			'Max',90,...
			'Value',0,...
			'Callback',updstrplstr);
% The slider on the upper edge. 
SkMp.ui3(4) = uicontrol('Units','normalized',...
			'Style','Slider',...
			'Position',[.1,.96,.8,.03],...
			'Min',0,...
			'Max',100,...
			'Value',45,...
			'Callback',updstrplstr);
% Pop-up menu for star magnitudes:
SkMp.ui3(5) = uicontrol('Units','normalized',...
			'Style','Popup',...
			'String','magn|2|2.5|3|3.5|4|4.5|5|5.5|6|6.5|7|7.5|8|8.5|9|9.5',...
			'Position',[.01,.94,.075,.05],...
			'Min',-180,...
			'Max',180,...
			'Value',8,...
			'Callback',updstrplstr);
% Uimenues:
SkMp.uic3(1,1) = uimenu('Label','File');
SkMp.uic3(1,2) = uimenu(SkMp.uic3(1,1),...
			'Label','Figure',...
			'Callback','figure',...
			'position',1);
SkMp.uic3(1,3) = uimenu(SkMp.uic3(1,1),...
			'Label','Close',...
			'Callback','skmp_close',...
			'position',2);
SkMp.uic3(1,4) = uimenu(SkMp.uic3(1,1),...
			'Label','Page setup',...
			'Callback','pagesetupdlg',...
			'position',3);
SkMp.uic3(1,5) = uimenu(SkMp.uic3(1,1),...
			'Label','Print',...
			'Callback','printdlg',...
			'position',4);
SkMp.uic3(1,6) = uimenu(SkMp.uic3(1,1),...
			'Label','Preferences',...
			'position',5);
SkMp.uic3(1,7) = uimenu(SkMp.uic3(1,6),...
			'Label','Default',...
			'Callback','SkMp = s_preferences(SkMp,0);');
SkMp.uic3(1,7) = uimenu(SkMp.uic3(1,6),...
			'Label','Plot',...
			'Callback','SkMp = s_preferences(SkMp,2);');
SkMp.uic3(1,8) = uimenu(SkMp.uic3(1,6),...
			'Label','Plot color',...
			'Callback','SkMp = s_preferences(SkMp,3);');
SkMp.uic3(1,9) = uimenu(SkMp.uic3(1,6),...
			'Label','Plot sizes',...
			'Callback','SkMp = s_preferences(SkMp,4);');

SkMp.uic3(2,1) = uimenu('Label','Pos/time');
SkMp.uic3(2,2) = uimenu(SkMp.uic3(2,1),...
			'Label','Display Pos/time',...
			'Callback','skmp_disp_pos_time(SkMp)');
SkMp.uic3(2,3) = uimenu(SkMp.uic3(2,1),...
			'Label','New Pos/time',...
			'Callback',checkokstr);
SkMp.uic3(3,1) = uimenu('Label','Star');
SkMp.uic3(3,2) = uimenu(SkMp.uic3(3,1),...
			'Label','Inform',...
			'Callback','[SkMp,staraz,starze,starid,starmagn,thisstar] = updstrinfo(SkMp);');
SkMp.uic3(3,3) = uimenu(SkMp.uic3(3,1),'Label','Plot star spectra','Callback','[ph,SkMp]=plotspec(SkMp);');
SkMp.uic3(3,4) = uimenu(SkMp.uic3(3,1),'Label','assign star spectra','Callback','guigetspec(SkMp)');
SkMp.uic3(3,5) = uimenu(SkMp.uic3(3,1),'Label','Ra/decl','Callback',str0);
SkMp.uic3(3,6) = uimenu(SkMp.uic3(3,1),'Label','Azim/Zen','Callback',str1);

SkMp.uic3(4,1) = uimenu('Label','Help');
SkMp.uic3(4,2) = uimenu(SkMp.uic3(4,1),...
			'Label','Help',...
			'Callback','skyhelp(5)');
SkMp.uic3(4,3) = uimenu(SkMp.uic3(4,1),...
			'Label','WARRANTY',...
			'Callback','skyhelp(6)');
SkMp.uic3(4,4) = uimenu(SkMp.uic3(4,1),...
			'Label','Copyright',...
			'Callback','skyhelp(7)');


set(SkMp.uic3(:),'handlevisibility','callback')
set(SkMp.ui3(:),'handlevisibility','callback')

if ( version_nr > 5.1 )
  
  set(SkMp.ui3(1),'TooltipString','Change NORTH-SOUTH angle');
  set(SkMp.ui3(2),'TooltipString','Change ROLL angle');
  set(SkMp.ui3(3),'TooltipString','Change EAST-WEST angle');
  set(SkMp.ui3(4),'TooltipString','Change FIELD OF VIEW angle');
  set(SkMp.ui3(5),'TooltipString','Change MAGNITUDE OF FAINTEST STAR');
  
else
  
  set(SkMp.uic3(1,4),'Callback','pagedlg')
  
end
if nargin > 1
  
  SkMp.ui815 = [];
  SkMp.tid0 = time;
  SkMp.pos0 = pos;
  [SkMp] = checkisok(SkMp);
  
else
  
  [stnnames,SkMp] = checkok(SkMp);
  
end

if nargout == 0
  
  assignin('base','SkMp',SkMp)
  
end
