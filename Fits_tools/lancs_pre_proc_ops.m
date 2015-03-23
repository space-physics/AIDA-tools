function PO = lancs_pre_proc_ops(pp_type)
% LANCS_PRE_PROC_OPS - Typical ALIS-fits preprocessing options
% struct 
%
% Calling:
%   PO = typical_pre_proc_ops(pp_type)
% 
% Input:
%   PP_TYPE - string [{'alis'}|'none'|'standard'|'sbig'|'afrl-raw']


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

PO.filetype = 'fits';  % Image format of files to
                       % read. [{'fits'}|'sbig'|'afrl-raw']. If
                       % other format function will look for a
                       % field PO.read_data_fcn, if that is a
                       % function handle, it will be used to read
                       % the file. If there is no such field the
                       % fallback is to attempt to read
                       % the file with imread, if that also fails
                       % the last effort is made with loading the
                       % file with matlab 'load'.

PO.quadfix = 0;        % number of overscan strips
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
PO.bzero_sign = 1;    % Default is to subtract BZERO, set to 1 if
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

PO.log2obs = @lancs_apogee_fits;


if nargin == 0
  return
end

tp = lower(pp_type);

switch tp
 case 'alis'
  PO.read_data_fcn = 'fits';
  PO.quadfix = 2;        % number of overscan strips
  return
 case 'none'
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
 case 'sbig'
  PO.filetype = 'sbig';
 case 'arfl-raw'
  PO.filetype = 'arfl-raw';
 otherwise
end
