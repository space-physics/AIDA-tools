function PO = typical_pre_proc_ops(pp_type,varargin)
% TYPICAL_PRE_PROC_OPS - Typical ALIS-fits preprocessing options
% struct 
%
% Calling:
%   PO = typical_pre_proc_ops(pp_type)
%   PO = typical_pre_proc_ops(pp_type,fieldname1,value1,...)
% 
% Input:
%   PP_TYPE - string [{'alis'}|'none','standard','afrl-raw','afrl-keo', 'miracle-asc','PGI-ASC']
% Output:
%  PO - structure with fields directing image pre-processing.
%       Contains fields:
% filetype = Image format of files to
%            read. [{'fits'}|'sbig'|'afrl-raw'|'afrl-keo']. If
%            other format function will look for a
%            field PO.read_data_fcn, if that is a
%            function handle, it will be used to read
%            the file. If there is no such field the
%            fallback is to attempt to read
%            the file with imread, if that also fails
%            the last effort is made with loading the
%            file with matlab 'load'.
% quadfix = 2;       number of overscan strips, set to 0 for no
%                    overscan-strips and no OS-correction
% quadfixsize = 0;   size of overscanstrip 0 => cunning guess
% replaceborder = 1; replace image border or not
% badpixfix = 1;     correct bad pixels
% outimgsize = 0;    post-binning/resampling image to size; 0 => no rescaling
% medianfilter = 3;  array of filtersizes cascading filtering (
%                    medianfilter > 0, wienerfilter < 0 ),
%                    example PO.medianfilter = [3 -5] -> 
%                    wiener2(medfilt2(I,[3 3]),[5 5])
% 
% defaultccd6 = 1;      default handling of ccdcam 6
% bias_correction = 1;  Bias correction from bias-file.
% bzero_sign = -1;      Default is to subtract BZERO, set to 1 if
%                       you want to add BZERO.
% 
% imreg = [];   cut to region of interest [xmin,xmax,ymin,ymax], if
%               empty read whole image.
% 
% C_cam = [];   pixel sensitivity, either scalar or size of image
% 
% remove_these_stars = [];  remove stars (cmp bad pixels)
%                           - requires OPTPAR as well)
% optpar = [];
% size_r_t_s = 2;  % half size (pixels) of removed stars -1
% 
% v_interf_notches = [];  notch frequencies for removal of
%                         vertical interference pattern
% psf  = [];  psf to deconvolve with (preferably not done here
%             for ALIS)
% ffc = [];   do flatfield correction automatically, requires OPTPAR
% 
% fix_missalign = 0;  Query the user for improvment of
%                     auto-loaded optical parameters when they
%                     are offline. Set to zero or fix the problem
%                     when running analysis that loads many
%                     images
% verb = 0;           Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
%                     more warnings
%                     'q','q1','quiet','q2', more talkative: 'v'
% 
% interference_level = inf;     Cut-off intensity level for
%                               automatic high frequency
%                               interference removal. Typical
%                               Values range from 2-4. Lower
%                               values removes more
%                               frequencies. Inf - no filtering.
% interference_method = 'flat'; Wheighting method. [{'flat'}| 'interp','weighed']
% interference_swf = 3;         Size of wiener-filter for fourier
%                               transform. To increase its size makes little to very
%                               little difference.
% img_histeq = 0;
% hist_crop = 0;
% 
%  Function handle to functions creating OBS-structure with meta-data:
% try_to_be_smart_fnc = '';  Function that creates meta-data from filename
% log2obs = '';              Function that creates meta-data from header
% read_data_fcn = '';  Function handle to function reading image
%                      from filename [H,Img] = read_data_fcn(filename)
% 
% find_optpar = 0;    Automatic searching of optical parameters.
% 
% StarCalResDir = pwd; Default directory for saving calibration and
%                      other results.
% keep_rgb    =  0;   Set to 1 for keeping R-G-B planes seaprately,
%                     otherwise RGB-images are converted to
%                     gray-scale images, either from the V plane
%                     after rgb2hsv or simply R+G+B
% 
% Default defaults listed, for specified image formats defaults
% might vary accordingly.
% 
% See also: PRE_PROC_IMG, INIMG, TRY_TO_BE_SMART

%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
%
% miracle_asc added 6/2010 MV

PO.filetype = 'fits';  % Image format of files to
                       % read. [{'fits'}|'sbig'|'afrl-raw'|'afrl-keo']. If
                       % other format function will look for a
                       % field PO.read_data_fcn, if that is a
                       % function handle, it will be used to read
                       % the file. If there is no such field the
                       % fallback is to attempt to read
                       % the file with imread, if that also fails
                       % the last effort is made with loading the
                       % file with matlab 'load'.
PO.quadfix = 2;        % number of overscan strips
PO.quadfixsize = 0;    % size of overscanstrip 0 => cunning guess
PO.replaceborder = 1;  % replace image border or not
PO.badpixfix = 1;      % correct bad pixels
PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
PO.medianfilter = 3;   % array of filtersizes cascading filtering (
                       % medianfilter > 0, wienerfilter < 0 ),
                       % example PO.medianfilter = [3 -5] -> 
                       % wiener2(medfilt2(I,[3 3]),[5 5])

PO.defaultccd6 = 1;    % default handling of ccdcam 6
PO.bias_correction = 1;
PO.bzero_sign = -1;    % Default is to subtract BZERO, set to 1 if
                       % you want to add BZERO.

PO.imreg = []; % cut to region of interest [xmin,xmax,ymin,ymax]

PO.C_cam = []; % pixel sensitivity, either scalar or size of image

PO.remove_these_stars = []; % remove stars (cmp bad pixels)
                            % - requires OPTPAR as well')
PO.optpar = [];
PO.size_r_t_s = 2;  % size (pixels) of removed stars')

PO.v_interf_notches = []; % notch frequencies for removal of
                          % vertical interference pattern
PO.psf  = []; % psf to deconvolve with (preferably not done here
              % for ALIS)
PO.ffc = [];  % do flatfield correction automatically, requires OPTPAR

PO.fix_missalign = 0; % Query the user for improvment of
                      % auto-loaded optical parameters when they
                      % are offline. Set to zero or fix the problem
                      % when running analysis that loads many
                      % images
PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
                      % more warnings
                      % 'q','q1','quiet','q2', more talkative: 'v'

PO.interference_level = inf;    % Cut-off intensity level for
                                % automatic high frequency
                                % interference removal. Typical
                                % Values range from 2-4. Lower
                                % values removes more
                                % frequencies. Inf - no filtering.
PO.interference_method = 'flat';% Wheighting method. [{'flat'}| 'interp','weighed']
PO.interference_swf = 3;        % Size of wiener-filter for fourier
                                % transform. To increase its size makes little to very
                                % little difference.
PO.img_histeq = 0;
PO.hist_crop = 0;

PO.try_to_be_smart_fnc = '';
PO.log2obs = '';
PO.read_data_fcn = '';

PO.find_optpar = 0;   % Automatic searching of optical parameters.


PO.skip_dialogs = 1;

PO.StarCalResDir = pwd; % Default directory for saving optical
                        % parameters.
%% This version to save optical parameters in the home directory:
% PO.StarCalResDir = getenv('HOME');
%% This version to save optical parameters in the AIDA_tools .data
%  (something similar to this
%  /home/bjorn/aida_newester/.data/OpticalParameters/) directory:
try
  % [f1,f2,f3] = fileparts(which('AIDA_startup'));
  [f1] = fileparts(which('AIDA_startup'));
  PO.StarCalResDir = fullfile(f1,'.data','OpticalParameters');
catch
end

if nargin == 0
  return
end


tp = lower(pp_type);
switch tp
 case 'alis'
  PO.read_data_fcn = 'fits';
  PO.central_station = 1;
  %PO.StarCalResDir = '/export/data/bjg1c10/ALIS/ACC';
  return
 case 'none'
  PO.filetype = '';      % Image format of files to
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.bzero_sign = 0;    % Default is to subtract BZERO, set to 1 if
 case 'sbig'
  PO.filetype = 'sbig';      % Image format of files to
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.bzero_sign = 0;    % Default is to subtract BZERO, set to 1 if
 case 'standard'
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 1;  % replace image border or not
  PO.badpixfix = 1;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 3;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.bzero_sign = 0;    % Default is to subtract BZERO, set to 1 if
 case 'miracle_asc'
  PO.filetype = 'miracle_asc'; % Image format of files of miracle ASCs
  PO.SODemccd_flag = 0;  % Flag used to flip SOD emccd images when using 
                         % traditional ccd output 0=doesn't flip, 1=flip the image l-r 
  PO.flipimage = 1;      % takes care of the fact that png and jpg images are read upside
                         % down when using imagesc and axis xy.
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.bzero_sign = 0;    % Default is to subtract BZERO, set to 1 if
  PO.central_station=710;
 otherwise
end

if strcmp(pp_type,'afrl-raw')
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.bzero_sign = 0;    % Default is to subtract BZERO, set to 1 if
  PO.filetype = 'afrl-raw';  % Image format of files to
                       % read. [{'fits'}|'sbig'|'afrl-raw'|'afrl-keo']. If
  PO.central_station = 401;
elseif strcmp(pp_type,'afrl-keo')
  
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.filetype = 'afrl-keo';  % Image format of files to
  PO.central_station = 401;
  
elseif strcmp(pp_type,'PGI-ASC')
  
  PO.find_optpar = 0;
  PO.quadfix = 0;        % number of overscan strips
  PO.replaceborder = 0;  % replace image border or not
  PO.badpixfix = 0;      % correct bad pixels
  PO.outimgsize = 0;     % post-binning/resampling image to size; 0 => no rescaling
  PO.medianfilter = 0;   % array of filtersizes cascading filtering (
  PO.defaultccd6 = 0;    % default handling of ccdcam 6
  PO.bias_correction = 0;
  PO.fix_missalign = 0; % Query the user for improvment of
  PO.verb = 0;          % Verbosity, [ -2 | -1 | {0} | 1 | 2 ] larger
  PO.interference_level = inf;    % Cut-off intensity level for
  PO.filetype = 'PGI-ASC';  % Image format of files to
  PO.central_station = 12;
  PO.precision = 'uint8';
  PO.frames = [];
end

if ~isempty(varargin)
  for i1 = 1:2:length(varargin),
    PO.(varargin{i1}) = varargin{i1+1};
  end
end
