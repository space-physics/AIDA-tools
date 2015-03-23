function callbackFcn4PointsOverImg(ImgName,long0lat0alt0,longlatalt,optpar,imReg,titleStr,lblStrs,gridstyle)
% callbackFcn4PointsOverImg - wrapping of 2 functions for ASC image overplotting
%  This function is a simple wrapping of IMREAD and IMG_OVERPLOT_LLH
%  to construct a suitable callback for making a gui that can pull
%  all-sky camera images and plot the image projection of a number
%  of desired 3-D points.
% 
% Calling:
%  callbackFcn4PointsOverImg(ImgName,long0lat0alt0,longlatalt,optpar,imReg,titleStr,lblStrs,gridstyle)
% Input:
%  ImgName       - Cell array with file-names to images to read,
%                  autoupdated url-s to "most recent image" seems
%                  most useful.
%  long0lat0alt0 - Cell array (1 x nCams) with location [long, lat, alt]
%                  (deg, deg, km) of the imagers.
%  longlatalt    - double array [nPoints x 3] with longitude,
%                  latitude and altitude of the points to project
%                  onto the image plane (deg, deg, km)
%  optpar        - optical parameters specifying the geometric
%                  characteristics of the camera, as obtained with
%                  STARCAL 
%  imReg         - Cell array with image regions used in the star-
%                  calibration.
%  titleStr      - Cell array with title strings (typically name of
%                  site where ASC is located)
%  lableStr      - Cell array with label strings (typically
%                  number/name of overplotted points.
%  gridstyle     - [{'ll'}| 'az-ze' | ''] flag for selection of
%                  gridlines to plot, ll - longitide-latitude grid,
%                  az-ze - azimuth-zenith grid, '' (empty) no grid.

% Copyright © 20121013 Björn Gustavsson
% This is free software, licensed under GNU GPL version 3 or later.

D = imread(ImgName);
%D = D(imReg(3):imReg(4),imReg(1):imReg(2),:);
img_overplot_llh(D,long0lat0alt0,longlatalt,optpar,imReg,titleStr,lblStrs,gridstyle);
