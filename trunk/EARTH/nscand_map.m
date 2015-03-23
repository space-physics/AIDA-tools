function PH = nscand_map(latlong_or_xyz,axlim)
% NSCAND_MAP - plot topographic mat over northern Scandinavia
%   
% Calling:
%  PH = nscand_map(latlong_or_xyz,axlim)
% Input:
%  latlong_or_xyz - string/flag 'l' for plotting the map on
%                   lat-long grid, otherwise on cartesian
%                   coordinates
%  axlim          - [long1 long2 lat1 lat2] (degrees) or 
%                   [xmin xmax ymin ymax] (km) defined by user as
%                   appropriate.

%   Copyright � 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
%   CSW 201203, minor bug in limits to build up relevant matrices

%Was: if nargin & strcmp(lower(latlong_or_xyz(1)),'l')
if nargin && strcmpi(latlong_or_xyz(1),'l')
  load NS-geography.mat Long_Nscand Lat_Nscand Nscand
  if nargin == 2 && ~isempty(axlim)
    
    % Find indices for longitude/latitude to build up the corresponding
    % matrices
    [rte, indlon1] = min(abs(Long_Nscand(1,:) - axlim(1)));
    [rte, indlon2] = min(abs(Long_Nscand(1,:) - axlim(2)));
    [rte, indlat1] = min(abs(Lat_Nscand(:,1) - axlim(3)));
    [rte, indlat2] = min(abs(Lat_Nscand(:,1) - axlim(4)));
    Long2plot_Nscand = Long_Nscand(indlat2:indlat1,indlon1:indlon2);
    Lat2plot_Nscand  = Lat_Nscand(indlat2:indlat1,indlon1:indlon2);
    Nscand2plot      = Nscand(indlat2:indlat1,indlon1:indlon2);
    
    % Long2plot_Nscand = Long_Nscand(axlim(3)<Lat_Nscand&Lat_Nscand<axlim(4),axlim(1)<Long_Nscand&Long_Nscand<axlim(2));
    % Lat2plot_Nscand  = Lat_Nscand(axlim(3)<Lat_Nscand&Lat_Nscand<axlim(4),axlim(1)<Long_Nscand&Long_Nscand<axlim(2));
    % Nscand2plot      = Nscand(axlim(3)<Lat_Nscand&Lat_Nscand<axlim(4),axlim(1)<Long_Nscand&Long_Nscand<axlim(2));
    ph = tcolor(Long2plot_Nscand,Lat2plot_Nscand,Nscand2plot);shading flat
  else
    ph = tcolor(Long_Nscand,Lat_Nscand,Nscand);shading flat
  end
else %if nargin & strcmpi(latlong_or_xyz(1),'c')
  load NS-geography.mat Nscand xNscand yNscand %zNscand
  if nargin == 2 && ~isempty(axlim)
    % Find indices for x/y to build up the corresponding
    % matrices
    [rte, indx1] = min(abs(xNscand(1,:) - axlim(1)));
    [rte, indx2] = min(abs(xNscand(1,:) - axlim(2)));
    [rte, indy1] = min(abs(yNscand(:,1) - axlim(3)));
    [rte, indy2] = min(abs(yNscand(:,1) - axlim(4)));
    xNscand2p = xNscand(indy2:indy1,indx1:indx2);
    yNscand2p = yNscand(indy2:indy1,indx1:indx2);
    Nscand2p  = Nscand(indy2:indy1,indx1:indx2);
    
    % xNscand2p = xNscand(axlim(3)<yNscand&yNscand<axlim(4),axlim(1)<xNscand&xNscand<axlim(2));
    % yNscand2p = yNscand(axlim(3)<yNscand&yNscand<axlim(4),axlim(1)<xNscand&xNscand<axlim(2));
    % Nscand2p  = Nscand( axlim(3)<yNscand&yNscand<axlim(4),axlim(1)<xNscand&xNscand<axlim(2));
    ph = tcolor(xNscand2p,yNscand2p,Nscand2p);shading flat
  else
    ph = tcolor(xNscand,yNscand,Nscand);shading flat
  end
end
if nargout
  PH = ph;
end
