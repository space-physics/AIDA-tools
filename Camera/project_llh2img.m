function [u,v,uG,vG,cG1,cG2] = project_llh2img(longlatalt,long0lat0alt0,optpar,imsiz,gridstyle)
% PROJECT_LLH2IMG - project a point in space LONGLATALT down onto an image
%  point [U,V]. The imager is located in LONG0LAT0ALT0 and the 
%  optical transfer is caracterized by OPTPAR. IMSIZ is the size of
%  the image.
%
% Calling:
%  [u,v,uG,vG] = project_llh2img(longlatalt,long0lat0alt0,optpar,imsiz)
% 
% Input:
%  long0lat0alt0 - [1x3] array for camera position [long,lat,alt] (degrees, km).
%  longlatalt    - [nx3] array of point coordinates (degrees, km) .
%  optpar - parameters for optical model focal widths, camera
%           rotation angles, image coordinates (relative units) for
%           projection point of optical axis, shape factor, optical
%           model.
%  imsiz  - size of image.
%
% See also CAMERA_BASE, CAMERA_MODEL, INV_PROJECT_POINT

%   Copyright � 20121013 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

long = longlatalt(:,1);
lat = longlatalt(:,2);
alt = longlatalt(:,3);
long0 = long0lat0alt0(1);
lat0 = long0lat0alt0(2);
alt0 = long0lat0alt0(3);

% Convert the longitude-latitude-altitude to cartesian coordinates
% in the local horizontal coordinate system centred in 
% [long0, lat0 alt0]. 
% TODO: This should be possible to vectorize...
for i1 = length(alt):-1:1,
  [r(i1,1),r(i1,2),r(i1,3)] = llh_to_local_coord(lat0,long0,alt0,...
                                                 lat(i1),long(i1),alt(i1));
end

% Calculate the pixel coordinates of the image projections of the
% points:
[u,v] = project_point([0 0 0],optpar,r',eye(3),imsiz);

if nargout > 2
  if strcmp(gridstyle,'ll')
    % If the number of ouput arguments are 4 then calculate the image
    % coordinates of a long-lat grid centred above the camera
    % coordinates too...
    longGrid0 = round(long0) + [-5:.5:5];
    latGrid0 = round(lat0) +  [-2.5:.25:2.5];
    
    [longGrid,latGrid] = meshgrid(longGrid0,latGrid0);
    %for i1 = 1:size(latGrid,1),
    %  for i2 = 1:size(latGrid,2),
    for i1 = size(latGrid,1):-1:1,
      for i2 = size(latGrid,2):-1:1,
        [rG(1),rG(2),rG(3)] = llh_to_local_coord(lat0,long0,alt0,...
                                               latGrid(i1,i2),longGrid(i1,i2),alt(1));
        [uG(i1,i2),vG(i1,i2)] = project_point([0 0 0],optpar,rG',eye(3),imsiz);
      end
    end
    cG1 = longGrid0;
    cG2 = latGrid0;
  else
    % calculate the image coordinates of an azimuth-zenith grid too...
    azGrid0 = [0:360]*pi/180;
    zeGrid0 = [20:10:80]*pi/180;
    
    [azGrid,zeGrid] = meshgrid(azGrid0,zeGrid0);
    %for i1 = 1:size(azGrid,1),
    %  for i2 = 1:size(azGrid,2),
    for i1 = size(azGrid,1):-1:1,
      for i2 = size(azGrid,2):-1:1,
        [uG(i1,i2),vG(i1,i2)] = project_directions(azGrid(i1,i2),zeGrid(i1,i2),...
                                                     optpar,optpar(9),imsiz);
      end
    end
    cG1 = azGrid0;
    cG2 = zeGrid0;
  end
end
