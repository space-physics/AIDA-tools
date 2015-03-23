function starter4PointsOverImg(varargin)
% starter4PointsOverImg - starting function for ASC image overplotting
%  This function is a gui-creating function making a GUI for ASC
%  overplotting gui that can pull all-sky camera images and plot
%  the image projection of a number of desired 3-D points.
% 
% Calling:
%  starter4PointsOverImg(longlatalt,{ImgNames,titleStr,longlataltCams,optpar,imReg{,lblStr{,gridstyle}}})
% Input:
%  longlatalt    - double array [nPoints x 3] with longitude,
%                  latitude and altitude of the points to project
%                  onto the image plane (deg, deg, km). Defaults to
%                  footpoints and directions for the HARE campaign
%                  17.61, 77.20 (degrees), 105 km
%                  18.90, 76.18 (degrees), 105 km
%                  20.27, 74.80 (degrees), 105 km
%                  21.73, 72.75 (degrees), 105 km
%                  22.96, 69.91 (degrees), 105 km
%                  19.23, 69.58 (degrees), 105 km
%  ImgName       - Cell array with file-names to images to read,
%                  autoupdated url-s to "most recent image" seems
%                  most useful. Defaults to:
%                  {'http://polaris.nipr.ac.jp/~acaurora/aurora/Longyearbyen/latest.jpg',
%                   'http://polaris.nipr.ac.jp/~acaurora/aurora/Tromso/latest.jpg'};
%  long0lat0alt0 - Cell array (1 x nCams) with location [long, lat, alt]
%                  (deg, deg, km) of the imagers. Defaults to:
%                   {[16+2/60          78+09/60,        0.445],
%                    [19+13/60+38/3600 69+35/60+11/3600 0.086]};
%  optpar        - optical parameters specifying the geometric
%                  characteristics of the camera, as obtained with
%                  STARCAL. Defaults to:
%                  {[-0.73644 -0.72566 -1.0699 0.469 0.85278 0.0052725 -0.00043956 0.47421 2 0],
%                   [-0.73644 -0.72566 -1.0699 0.469 0.85278 0.0052725 -0.00043956 0.47421 2 0]};
%  imReg         - Cell array with image regions used in the star-
%                  calibration. Defaults to:
%                  {[132,590,15,480], [132,590,15,480]}
%  titleStr      - Cell array with title strings (typically name of
%                  site where ASC is located). Defaults to:
%                  {'ESR','Ramfjord'};
%  lableStr      - Cell array with label strings (typically
%                  number/name of overplotted points. Defaults to:
%                  {'1','2',...,sprintf('%d',nr_points)};
%  gridstyle     - [{'ll'}| 'az-ze' | ''] flag for selection of
%                  gridlines to plot, ll - longitide-latitude grid,
%                  az-ze - azimuth-zenith grid, '' (empty) no
%                  grid. Defaults to:
%                  'll'  
% 
% Notes: Either the function should be called with:
% * no input arguments - then it will run with defaults for all
%   parameters,
% * only the first input parameter - that array of points will be
%   used together with the default camera parameters
% * 6 (or 7) parameters, with either an empty first input parameter
%   (then the default points will be used together with the given
%   camera parameters) or with an array for the point
%   coordinates. The 7th input array will only control the grid
%   style.

% Copyright © 20121013 Björn Gustavsson
% This is free software, licensed under GNU GPL version 3 or later.




if nargin > 0 & ~isempty(varargin{1})
  longlatalt = varargin{1};
else
  longlatalt = [ 17.52843 77.06578 104.8983
                 18.81277 76.03857 104.7718
                 20.17844 74.64872 104.5892
                 21.63571 72.58227 105.2754
                 22.86825 69.71968 104.7995
                 19.15863 69.38518 104.695];
% $$$                  17.61 77.20 105
% $$$                  18.90 76.18 105
% $$$                  20.27 74.80 105
% $$$                  21.73 72.75 105
% $$$                  22.96 69.91 105
% $$$                  19.23 69.58 105];
end

gridstyle = 'll';
for i1 = 1:size(longlatalt,1)
  lblStr{i1} = sprintf('%d',i1);
end
if in_ranges(nargin,[1.1 5.9])
  error('starter4PointsOverImg expects either 0 1 6 7 or 8 input arguments with %d input argumetns things ought to go wonky',nargin)
elseif nargin > 5
  UrlNames =       varargin{2};  
  titleStrs =      varargin{3};
  longlataltCams = varargin{4};
  optpars =        varargin{5};
  ImRegS =         varargin{6};
  if nargin > 6
    lblStr = varargin{7};
  end
  if nargin > 7
    gridstyle = varargin{8};
  end
else
  
  UrlNames = {'http://polaris.nipr.ac.jp/~acaurora/aurora/Longyearbyen/latest.jpg',...
              'http://kho.unis.no/Quicklooks/kho_dslr.jpg',...
              'http://polaris.nipr.ac.jp/~acaurora/aurora/Tromso/latest.jpg',...
              'http://www.irf.se/allsky/LASTv2.JPG'};
  titleStrs = {'ESR-NIPR',...
               'ESR-UNIS',...
               'Ramfjord',...
               'Kiruna'};
  longlataltCams = {[16+2/60          78+09/60,        0.445],...
                    [16+2/60          78+09/60,        0.445],...
                    [19+13/60+38/3600 69+35/60+11/3600 0.086],...
                    [20.4112          67.8407,         0.2]};
  optpars = {[-0.7406   -0.7306   -0.6692  0.9842  27.8691   0.0024    -0.0023     0.4678  2 0],...
             [-0.67435  -0.67468   1.2732  1.2487  29.676    0.039831   0.0087395  0.5249  2 0],...
             [-0.73644  -0.72566  -1.0699  0.469    0.85278  0.0052725 -0.00043956 0.47421 2 0],...
             [-0.7062   -0.7055    0.0781  0.0215   9.5699  -0.0051    -0.0000     0.4751  2 0]};
  ImRegS = {[132,590,15,480],...
            [1,480,1,480],...
            [132,590,15,480],...
            [1 479,122 600]};
end
% KHO DSLR
% SkMp.img = SkMp.img(1:480,20:end);
% optp = [ -7.1740773e-01  -6.8878515e-01   3.2366751e+00 1.6978168e+00   4.0734457e+01   2.0467589e-02   8.5427099e-03 5.1304480e-01 2 0]
% http://kho.unis.no/Quicklooks/kho_dslr.jpg
figure
mh = uimenu(gcf,'Label','ASC-update','handlevisibility','off');

for i1 = 1:length(UrlNames),
  fcn{i1} = @(src,eventdata) callbackFcn4PointsOverImg(UrlNames{i1},...
                                                    longlataltCams{i1},...
                                                    longlatalt,...
                                                    optpars{i1},...
                                                    ImRegS{i1},...
                                                    titleStrs{i1},...
                                                    lblStr,...
                                                    gridstyle);
  eh{i1} = uimenu(mh,...
                  'Label',titleStrs{i1},...
                  'callback',fcn{i1},...
                  'handlevisibility','callback');
end

feval(fcn{1})
