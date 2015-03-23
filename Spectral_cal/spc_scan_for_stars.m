function [IDSTARS,STARPARS,filtnr,Stime,extime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS,disp_ops)
% SPC_SCAN_FOR_STARS - Scan images for stars in the Pulkovo
% spectrophotometric catalog - with known spectras.
% FILES is a strmat of images filenames, POS is [long, lat] of the
% observing point, OPTPAR is an array of optical parameters (see
% CAMERA). PO is the image pre-processing options - see INIMG for
% details. OPTS is the options related to this function: 
%  OPTS.Mag_limit - limiting faintest magnitude of stars to')
%                   search among')
%  OPTS.regsize   - Size of the region surrounding the star')
%  OPTS.bgtype    - Type of background subtraction used,')
%                   ''complicated'' or ''simple''.')
%
% Calling
%  [IDSTARS,STARPARS,filtnr,Stime] = spc_scan_for_stars(files,pos,optpar,PO,OPTS,disp_ops)
% Input:
%  files    - string array with filenames of images to look for
%             stars in ( nImgs x N )
%  pos      - longitude-latitude of observation location [1 x 2] (degrees)
%  optpar   - camera parameter vector or optpar struct, determining
%             the camera pixel lines-of-sight
%  PO       - Image pre-processing options struct, see
%             TYPICAL_PRE_PROC_OPS for details.
%  OPTS     - Options struct, see SPC_TYPICAL_OPS for details
%  disp_ops - set to 'iter' to get the incremental progression
%             displayed, this function is stressingly
%             time-consuming since it searches for the best-fitting
%             2-D Gaussian of N stars in nImgs number of images
%             which can take "some time".
% Output:
%  IDSTARS - Array with parameters of identified stars.
%            IDSTARS(n,1) - Running index
%            IDSTARS(n,2) - Horizontal image position (pixels) of 2D Gaussian
%            IDSTARS(n,3) - Vertical image position (pixels) of 2D Gaussian
%            IDSTARS(n,4) - Max of 2D Gaussian
%            IDSTARS(n,5) - Max image intensity of star
%            IDSTARS(n,6) - Total image intensity of star
%            IDSTARS(n,7) - Total image intensity of 2D Gaussian
%            IDSTARS(n,8) - Running index
%            IDSTARS(n,9) - Star index (BSC-NR)
%            IDSTARS(n,10) - Total error
%            IDSTARS(n,11) - Magnitude 
%  STARPARS - Parameters of the 2D Gaussian, see STARDIFF for details
%  filtnr   - Filter wavelength/number/identifier of images 
%             [nImgs x 1]
%  Stime    - Time of observation, (nImgs x 3) [h, m, s]
%  extime   - Exposure times for images (nImgs x 1) (s)
%  

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global stardir % bx by

if nargin == 0
  disp('OPTS should be a structure with the following optional fields: ')
  disp('   OPTS.Mag_limit - limiting faintest magnitude of stars to')
  disp('                    search among')
  disp('   OPTS.regsize   - Size of the region surrounding the star')
  disp('   OPTS.bgtype    - Type of background subtraction used,')
  disp('                    ''compicated'' or ''simple''.')
  
end

% default display option 
if nargin < 6
  disp_ops = 'off';
end

stardir = fileparts(eval('which(''skymap'')'));
%%%%%%% du maaste testa read_all_catalogs
readme_file = [stardir,'/stars/README.spectra'];
catalog_file = [stardir,'/stars/stars.dat'];
get_these_fields = [1 4 7 8 9 10 11 12 14 16];
star_list = read_all_astro_catalogs(catalog_file,readme_file,get_these_fields);
star_list = star_list(2:end);
star_list = fix_ra_decl(star_list);

if nargin >= 5 &  isfield(OPTS,'Mag_limit')
  
  %i = find([star_list(:).Vmag] <= OPTS.Mag_limit);
  %star_list = star_list(i);
  star_list = star_list([star_list(:).Vmag] <= OPTS.Mag_limit);
  
end

ra = [star_list(:).ra]';
decl = [star_list(:).decl]';

% image preprocessing options
if isempty(PO)
  PO = typical_pre_proc_ops;
  PO.outimgsize = 256;
  PO.LE = 1;
  PO.medianfilter = 0;
end

IDSTARS = [];
STARPARS = [];

disp('Searching for stars')
fprintf(1,'\n')
drawnow
progmeter(0,' ')


for i1 = 1:size(files(1:end,:),1),
  
  % disp([i1 i1/size(files(1:end,:),1)])
  [data,header,obs] = inimg(files(i1,:),PO);
  data = data/obs.exptime;
  [stars_azze(:,1),stars_azze(:,2)] = starpos2( ra,...
                                                decl,...
                                                obs.time(1:3),...
                                                obs.time(4:6),...
                                                obs.longlat(2),... % obs.pos(2)
                                                obs.longlat(1));   % obs.pos(1)
  
  stars_azze(:,3) = [star_list(:).HR]';
  stars_azze(:,4) = [star_list(:).Vmag]';
  
  Stars_azze = stars_azze(stars_azze(:,2)<pi/2,:);
  [idstars,stars_par] = star_int_search(data,optpar,optpar(9),Stars_azze,OPTS);
  
  filtnr(i1) = obs.filter;
  idstars(:,1) = i1;
  IDSTARS = [IDSTARS;idstars];
  STARPARS = [STARPARS;stars_par];
  Stime(i1,:) = obs.time(4:6);
  extime(i1) = obs.exptime;
  progmeter(i1/size(files(1:end,:),1),sprintf('Found %d in image %d out of',size(idstars,1),i1,size(files(1:end,:),1)));
end
progmeter clear

%  if strncmp(disp_ops,'iter',4)
%    disp([i1 i1/length(files(1:end,:))])
%  end
