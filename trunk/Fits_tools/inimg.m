function [img_out,img_head,obs] = inimg(filename,PREPRO_OPS)
% INIMG - reads and pre-process an image.
% 
% Calling:
% [img_out,img_head,obs] = inimg(filename,PREPRO_OPS)
% 
% INPUT:
%   FILENAME is a string with the filename to load.
%   PREPRO_OPS is a struct with preprocess options:
%   Possible fields are:
%    filetype           - image format to read [{'fits'}|'sbig'|'afrl-raw']
%    LE/BE              - File in little or big endian
%    defaultccd6        - Default unwrapping of ALIS camera 6
%    quadfix            - Quadrant balancing with over-scan-strips
%    quadfixsize        - size of overscan strip
%    bias_correction    - Remove zero level bias -  requires bias file
%                       - OK for some ALIS camera-binning combinations
%    replaceborder      - Replace outermost line/columns
%    C_cam              - pixel sensitivity, either scalar or size of image
%    badpixfix          - Fix bad pixels
%    imreg              - cut to region of interest in image
%    remove_these_stars - remove stars (cmp bad pixels)
%                       - requires optpar as well
%    size_r_t_s         - size (pixels) of removed stars
%    v_interf_notches   - remove vertical interference pattern
%    medianfilter       - medfilt2/wiener2/gen_susan filter image: 2-D
%                         med [sx sx] if positive, wiener if
%                         negative [-sx -sx], susan if complex,
%                         real part half-one-over-e-width of
%                         spatial Gaussian filter kernel
%                         (~exp(-Du^2/real(sx^2))), imaginary
%                         part scaling of intensity width
%                         (~exp(dI^2/(|im(sx)|*I))), if real(sx)<0
%                         include the center point -> similar to
%                         wiener, real(sx)>0 dont include center
%                         point: similar to median filtering
%    psf                - psf to deconvolve with (preferably not done here)
%    imreg              - cut from total image [xmin xmax ymin ymax]
%    outimgsize         - post-binning/resampling image
%    log2obs            - optional field that should be a function
%                         that takes an image header and makes an
%                         "obs-struct" with fields for obs-time
%                         [yyyy,mm,dd,hh,mm,ss], exposure time,
%                         wavelength, azimuth, zenith (degrees)
%                         latitude, longitude of the observation.
%    your_try_to_be_smart - optional field that should be a function
%                           that takes an image file-name and makes an
%                           "obs-struct" with fields for obs-time
%                           [yyyy,mm,dd,hh,mm,ss], exposure time,
%                           wavelength, azimuth, zenith (degrees)
%                           latitude, longitude of the observation.
%    (The last two is useful for files that not give enough
%    information in a (FITS-)header). Example functions can be
%    found in AIDA_tools/Fits_tools/File2obs/.
%    read_data_fcn - function handle to function to use for reading
%                    file if the file is neither a fits-file, a
%                    matlab-loadable file nor an imread-readable
%                    file. 
% 
%  See also READ_IMG, PRE_PROC_IMG


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin == 0
  
  help inimg
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
  % If no input arguments give a default PO-struct
  img_out = typical_pre_proc_ops;
  return
  
end

if nargin == 1
  [img_out,img_head,obs] = read_img(filename);
else
  [img_out,img_head,obs] = read_img(filename,PREPRO_OPS);
end
if isempty(img_out)
  % img_out is empty -> no image to preprocess
  return
end

if isfield(obs,'station') && ~isempty(obs.station)
  if nargin > 1 && isfield(PREPRO_OPS,'central_station')
    obs = AIDAstationize(obs,PREPRO_OPS.central_station);
  else
    obs = AIDAstationize(obs);
  end
end

% no preprocess option -> do no pre processing - duh!
if nargin > 1
  
  % Do pre-processing
  im_sz = size(img_out);
  if length(im_sz) > 2
    img_tmp = img_out;
    img_out = pre_proc_img(img_tmp(:,:,1),obs,PREPRO_OPS);
    for i1 = im_sz(3):-1:2,
      img_out(:,:,i1) = pre_proc_img(img_tmp(:,:,i1),obs,PREPRO_OPS);
    end
  else
    img_out = pre_proc_img(img_out,obs,PREPRO_OPS);
  end
end
