function [SkMp] = checkisok(SkMp)
% 
% "Private" function, not much use for a user to call this function
% 
% CHECKISOK - Callback from checkok. Takes care of loading
% of the star catalog and set up the relevant coordinates.
% 

%   Copyright � 20010402 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% global stardir

if ( ishandle(SkMp.ui815) )

  pos0(1) = str2num(get(SkMp.ui815,'String'));
  pos0(2) = str2num(get(SkMp.ui816,'String'));
  
  tid0(1) = str2num(get(SkMp.ui86,'String'));
  tid0(2) = str2num(get(SkMp.ui87,'String'));
  tid0(3) = str2num(get(SkMp.ui88,'String'));
  tid0(4) = str2num(get(SkMp.ui89,'String'));
  tid0(5) = str2num(get(SkMp.ui817,'String'));
  tid0(6) = str2num(get(SkMp.ui818,'String'));
  
  SkMp.pos0 = pos0;
  SkMp.tid0 = tid0;
  
  set(SkMp.ui812,'string','loading stars');
  set(SkMp.figchok,'pointer','watch')
  pause(.1)
  
end

%Gotcha! exist does not work on fields only on variables, functions, paths...
%
%if ( ~ exist( 'SkMp.oldfov' ) )
if (~isfield(SkMp,'oldfov'))
  fov = pi/4;
else
  fov = SkMp.oldfov;
end
%if ( ~ exist( 'SkMp.oldmagn' ) )
if(~isfield(SkMp,'oldmagn'))
  magn = 0;
else
  magn = SkMp.oldmagn;
end

%if ( ~ exist( 'SkMp.oldaz0' ) )
if(~isfield(SkMp,'oldaz0'))
  az0 = 0;
else
  az0 = SkMp.oldaz0;
end

%if ( ~ exist( 'SkMp.oldze0' ) )
if(~isfield(SkMp,'oldze0'))
  ze0 = 0;
else
  ze0 = SkMp.oldze0;
end

%if ( ~ exist( 'SkMp.oldrot0' ) )
if(~isfield(SkMp,'oldrot0'))
  rot0 = 0;
else
  rot0 = SkMp.oldrot0;
end


if isfield(SkMp,'SAO') && SkMp.SAO
  [possiblestars,star_list] = read_SAO(SkMp.pos0,SkMp.tid0(1:3),SkMp.tid0(4:6));
  SkMp.star_list = star_list;
else  
  [possiblestars,catalog] = loadstars2(SkMp.pos0,SkMp.tid0(1:3),SkMp.tid0(4:6));
  
  if nargin > 1
    
    %for i1 = 1:length(possiblestars),
    for i1 = length(possiblestars):-1:1,
      
      star_list(possiblestars(i1,3)).Azimuth = possiblestars(i1,1)*180/pi;
      star_list(possiblestars(i1,3)).Zenith = possiblestars(i1,2)*180/pi;
      star_list(possiblestars(i1,3)).App_Zenith = possiblestars(i1,end)*180/pi;
      
    end
    
  else
    
    SkMp.star_list = read_bsc(catalog,possiblestars);
    
  end
end
fov
[infovstars,SkMp] = infov2(possiblestars,-az0,-ze0,rot0,fov,SkMp);
plottstars = plottablestars2(infovstars,magn);

if ishandle(SkMp.figchok)
  close(SkMp.figchok)
end

SkMp.possiblestars = possiblestars;
SkMp.infovstars = infovstars;
SkMp.plottstars = plottstars;

figure(SkMp.figsky);
[SkMp] = updstrpl(SkMp);
