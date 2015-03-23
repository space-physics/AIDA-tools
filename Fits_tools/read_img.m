function [img_out,img_head,obs] = read_img(filename,PREPRO_OPS)
% READ_IMG - reads image data and process header info.
%   FILENAME is a string with the filename to load.
%   PREPRO_OPS is a struct with preprocess options:
% 
% Calling:
%  [img_out,img_head,obs] = read_img(filename,PREPRO_OPS)
%
%   Possible fields of PREPRO_OPS are:
%    LE/BE              - File in little or big endian')
%    defaultccd6        - Default unwrapping of ALIS camera 6')
%    quadfix            - Quadrant balancing with over-scan-strips')
%    quadfixsize        - size of overscan strip')
%    bias_correction    - Remove zero level bias -  requires bias file')
%                       - OK for some ALIS camera-binning combinations')
%    replaceborder      - Replace outermost line/columns')
%    C_cam              - pixel sensitivity, either scalar or size of image')
%    badpixfix          - Fix bad pixels')
%    imreg              - cut to region of interest in image')
%    remove_these_stars - remove stars (cmp bad pixels)')
%                       - requires optpar as well')
%    size_r_t_s         - size (pixels) of removed stars')
%    v_interf_notches   - remove vertical interference pattern')
%    medianfilter       - median/wiener filter image')
%    psf                - psf to deconvolve with (preferably not done here)')
%    imreg              - cut from total image [xmin xmax ymin ymax]')
%    outimgsize         - post-binning/resampling image')



%   Copyright © 1997-2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin == 0
  
  help read_img
  disp('possible preprocessing steps:')
  disp('LE/BE              % File in little or big endian')
  disp('defaultccd6        % Default unwrapping of ALIS camera 6')
  disp('quadfix            % Quadrant balancing with over-scan-strips')
  disp('quadfixsize        % size of overscan strip')
  disp('bias_correction    % Remove zero level bias -  requires bias file')
  disp('                   % OK for some ALIS camera-binning combinations')
  disp('replaceborder      % Replace outermost line/columns')
  disp('C_cam              % pixel sensitivity, either scalar or size of image')
  disp('badpixfix          % Fix bad pixels')
  disp('imreg              % cut to region of interest in image')
  disp('remove_these_stars % remove stars (cmp bad pixels)')
  disp('                   % requires optpar as well')
  disp('size_r_t_s         % size (pixels) of removed stars')
  disp('v_interf_notches   % remove vertical interference pattern')
  disp('medianfilter       % median/wiener filter image')
  disp('psf                % psf to deconvolve with (preferably not done here)')
  disp('imreg              % cut from total image [xmin xmax ymin ymax]')
  disp('outimgsize         % post-binning/resampling image')
  disp(' ')
  % If no input arguments give the default PO-struct
  img_out = typical_pre_proc_ops;
  return
  
end

if nargin == 1
  % Just get a default P_O-struct
  PREPRO_OPS = typical_pre_proc_ops('n');
  
end

if isstruct(filename)
  filename = filename.name;
end
%img_out = [];
img_head = [];
obs = [];

flt = PREPRO_OPS.filetype;
switch flt
 case 'fits'
  % For reading fits images we have to possibly adjust for ALIS
  % images being in either LE or BE. PREPRO_OPS should have a field
  % telling which Endian the images is.
  if isfield(PREPRO_OPS,'frames')
    
    fp = fopen(filename,'r','ieee-be');
    info = fitsinfo(filename);
    img_head =  fits_header(fp,filename);
    FUN = @(A) strcmp(A,'BITPIX');
    iqwe = find(arrayfun(FUN,{info.PrimaryData.Keywords{:,1}}));
    info.bitpix = info.PrimaryData.Keywords{iqwe,2};

    % TODO: fix the filename2parseheader!
    obs = fits_header2infostruct(img_head,PREPRO_OPS.filename2parseheader,PREPRO_OPS);
    obs.time(6) = obs.time(6) + obs.interval_t*PREPRO_OPS.frames(1);
    %obs = try_to_be_smart(img_head);
    [img_out] = fits_frames(fp,info,PREPRO_OPS.frames);
    obs.le_oR_BE = 'BE';
    fclose(fp);
    return
  elseif isfield(PREPRO_OPS,'LE')
    
    [img_head,img_out] = fits1(filename);
    le_oR_BE = 'LE';
    
  elseif isfield(PREPRO_OPS,'BE')
    
    [img_head,img_out] = fits2(filename);
    le_oR_BE = 'BE';
    
  else % Otherwise we have to try both and se which is mangled
    
    % Reading the file in both LE and BE and then automatically guess
    % which is better...
    [img_out2,img_out2] = fits2(filename);
    [img_head,img_out] = fits1(filename);
    if isempty(img_out)
      return
    end
    le_oR_BE = 'LE';
    if sum(sum(abs(del2(img_out2))))<sum(sum(abs(del2(img_out))))
      img_out = img_out2;
      le_oR_BE = 'BE';
      clear img_out2
    end
    
  end
 case 'sbig' % For reading files in SBIG format. Almost fits.
  [img_head,img_out,img_head] = sbig(filename);
 case 'afrl-raw' % For reading AirForce Research Labs raw image format
  [img_out,obs] = read_arl_raw(filename);
  img_head = [];
  if ~isempty(PREPRO_OPS.log2obs)
    obs = PREPRO_OPS.log2obs(obs);
  end
  % And then we're done!
  return
 case 'afrl-keo' % For reading AirForce Research Labs raw image format
  [img_out,obs] = read_arl_keo(filename);
  img_head = [];
  % And then we're done!
  return
  
 case 'PGI-ASC' % For reading AirForce Research Labs raw image format
  [img_out,obs] = read_PGIASC(filename,PREPRO_OPS.frames,PREPRO_OPS.precision);
  img_head = [];
  % And then we're done!
  return
  
 case 'KASC' % For reading Kiruna All-sky camera
  [img_out,obs] = read_KASC(filename);
  img_head = [];
  % And then we're done!
 return 

 case 'miracle_asc' % used to read MIRACLE ASC images
  %[img_out,obs,h]= read_miracle_asc(filename);
  [img_out,obs,h]= read_miracle(filename);
  img_head=h;
  %Here we have to check whether to load existing projection
  %parameters. The rest of this script will be ignored.
  if PREPRO_OPS.find_optpar
    optpar = find_optpar(obs,PREPRO_OPS);
    if ~isempty(optpar)
      obs.optpar = optpar;
    else
      error('No matching optical parameters found')
    end
  end
  % And then we're done!
  return

  % Here is where to add function calls for other formats.
 case 'SF-png'
  [img_head,img_out] = imwrapper(filename);
  obs = FMInSGOpng2obs(filename);
  return
  
 case 'taco-pgm' %Torsten Aslaksen's PGM format
  img_out = imread(filename); %handles PGM
  [a,b] = system(['tacodate2 ',filename]);
  obs.time = str2num(b);
  obs.camnr = 0;
  obs.station = 11; % input('Station (ALIS numbering, Ramfjord=11) ? Yup!');
  obs.optpar = [-3.17 -3.17 4.5 -17.5 7.5 0 0 1 1 0];
  %Comment out - these are just for 2011 Eiscat setup in
  %Mike Kosch's hut
  % And then we're done!
  return
  
 otherwise 
  % and here is where we read other formats that have not yet made
  % it into the permanent realm
  % 
  % First try reading files with a supplied function handle
  if ( isfield(PREPRO_OPS,'read_data_fcn') && ...
     ~isempty(PREPRO_OPS.read_data_fcn) )
    try
      [img_head,img_out] = PREPRO_OPS.read_data_fcn(filename);
    catch
      [img_head,img_out] = feval(PREPRO_OPS.read_data_fcn,filename);
    end
  else
    if isfield(PREPRO_OPS,'keep_rgb') && PREPRO_OPS.keep_rgb
      img_out = double(imread(filename));
    else
      % Try with imread and load
      [img_out] = inputall(filename);
    end
  end
  % To be sure: cast to double explicitly.
  if ( length(size(img_out)) > 2 )
    if isfield(PREPRO_OPS,'keep_rgb') && PREPRO_OPS.keep_rgb
    else
      img_out = sum(double(img_out),3);
    end
  else
    
    img_out = double(img_out);
    
  end
  
end
% In case img_out is empty just return with empty out_args and hope
% for the best.
if isempty(img_out)
  return
end
% Else proceed:
% By here the image data should be read.
% 
% What remains is to parse information about the image, from an
% image header or by some other means

% If no handles to either a log2obs-function of a
% try_to_be_smart-function is provided
if ( isempty(PREPRO_OPS.log2obs) && ...
     isempty(PREPRO_OPS.try_to_be_smart_fnc) )
  % we use the default one that works for ALIS-format fits
  % headers, and for other fits-headers it prompts for information
  % needed but not found.
  ai = fitsfindinheader(img_head,'ALIS');
  obs = try_to_be_smart(img_head,length(ai),PREPRO_OPS);
  if exist('le_oR_BE','var')
    obs.le_or_be = le_oR_BE;
  else
    obs.le_or_be = nan;
  end
elseif ~isempty(PREPRO_OPS.log2obs)
  try
    obs = PREPRO_OPS.log2obs(img_head);
  catch
    obs = feval(PREPRO_OPS.log2obs,img_head);
  end
elseif ~isempty(PREPRO_OPS.try_to_be_smart_fnc)
  try
    obs = PREPRO_OPS.try_to_be_smart_fnc(filename);
  catch
    obs = feval(PREPRO_OPS.try_to_be_smart_fnc,filename);
  end
else
  your_try_to_be_smart_type = exist('your_try_to_be_smart','file');
  if any(your_try_to_be_smart_type==[2 3 5 6])
    obs = your_try_to_be_smart(filename);
  else
    disp('You should make a file/function ''your_try_to_be_smart''')
    disp('This function should give the same kind of struct as the')
    disp('try_to_be_smart function. Now trying the standard one...')
    obs = try_to_be_smart(img_head,0,PREPRO_OPS);
  end
end
if PREPRO_OPS.find_optpar
  optpar = find_optpar(obs,PREPRO_OPS);
  obs.optpar = optpar;
end
