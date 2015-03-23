function [SkMp] = updstrplOld(SkMp)
%
% UPDSTRPL - Is the callback for all changes in the user interface
% of the 'skyview' figure. Here the changes in field of view,
% Azimuth, Zenith angles and the limiting magnitude is made to
% appear on the screen. 


%   Copyright © 19990222 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global bx

plottstars = SkMp.plottstars;
infovstars = SkMp.infovstars;
possiblestars = SkMp.possiblestars;

az0 = get(SkMp.ui3(3),'Value');
ze0 = get(SkMp.ui3(1),'Value');
fov = get(SkMp.ui3(4),'Value');
rot0 = get(SkMp.ui3(2),'Value');


if length(SkMp.ui3) > 6
  SkMp.slider_lock = get(SkMp.ui3(7), 'Value');
else
  SkMp.slider_lock = 0;
end

if isfield(SkMp,'optmod')
  
  % If there is no 'found_optpar' field we havent started the
  % optimization yet. Then we should take the optical parameters
  % for rotations and focla widths from the GUI-slidebars
  if SkMp.slider_lock == 0
    if isfield(SkMp, 'param_load')
      [fi,theta] = camera_invmodel(bx,0,SkMp.optpar,SkMp.optmod,size(SkMp.img));
      fov = abs(theta)*180/pi*fov/SkMp.oldfov;
    elseif SkMp.optmod ~= 2
      SkMp.optpar = [ sign(SkMp.optpar(1))*(1/2/tan(fov*pi/180)), ...
                      sign(SkMp.optpar(2))*(1/2/tan(fov*pi/180)), ...
                      az0, -ze0, rot0 0 0 0];
    else
      SkMp.optpar = [ sign(SkMp.optpar(1))*(1/2/sin(fov*pi/180)), ...
                      sign(SkMp.optpar(2))*(1/2/sin(fov*pi/180)), ...
                      az0, -ze0, rot0 0 0 1];
    end
    
  else
    
    [fi,theta] = camera_invmodel(bx,0,SkMp.optpar,SkMp.optmod,size(SkMp.img));
    fov = abs(theta)*180/pi*fov/SkMp.oldfov;
    
  end
  
end

magn = get(SkMp.ui3(5),'Value')/2+1;


set(SkMp.figsky,'pointer','watch')

[infovstars,SkMp] = infov2(possiblestars,az0,ze0,rot0,(fov+10)*pi/180,SkMp);
plottstars_prev = plottstars;
plottstars = plottablestars2(infovstars,magn);
if ~isempty(plottstars)
  starplot(plottstars,SkMp);
else
  display('WARNING: no new plottable stars found, using previous ones.');
  starplot(plottstars_prev,SkMp);
end

if isempty(SkMp.img)
  plotgrid(az0,ze0,rot0,SkMp.tid0(1:3),SkMp.tid0(4:6),SkMp.pos0(2),SkMp.pos0(1),SkMp.radecl_or_azze)
end

set(SkMp.figsky,'pointer','arrow')

SkMp.oldaz0 = az0;
SkMp.oldze0 = ze0;
SkMp.oldfov = fov;
SkMp.oldrot0 = rot0;
SkMp.oldmagn = magn;

SkMp.infovstars = infovstars;
SkMp.plottstars = plottstars;
