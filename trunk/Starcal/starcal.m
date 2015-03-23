function [SkMp] = starcal(varargin)
% STARCAL - startpoint for optical camera calibration. 
% 
% Calling:
% [SkMp] = starcal(varargin)
% 
% The function should be called with the litterary output
% above. The input could be: FILENAME, PRE_PROC_OPS
%                        or: FILENAME
%                        or: PRE_PROC_OPS
% where PRE_PROC_OPS should be a structure of the type output from
% TYPICAL_PRE_PROC_OPS 
% 
% See also TYPICAL_PRE_PROC_OPS

%   Copyright � 2001-11-05 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

ALIS_FITS = 0;

verstr = version;
version_nr = str2num(verstr(1:3));

if numel( varargin{1} ) > 127^2 % prod( size(varargin{1}) ) > 127^2
  
  cal_image = varargin{1};
  obs = varargin{2};
  if isfield(obs,'alis_fits')
    ALIS_FITS = obs.alis_fits;
  else
    ALIS_FITS = 0;
  end
  if isfield(obs,'filename')
    filename = obs.filename;
  else
    filename = '';
  end
  
else
  
  if nargin == 2
    
    filename = varargin{1};
    PREPROC_OPS = varargin{2};
    
  elseif nargin == 1 && ~isstruct(varargin{1})
    
    filename = varargin{1};
    
    PREPROC_OPS = typical_pre_proc_ops('alis');
    PREPROC_OPS.quadfix = 2;          % number of overscan strips
    PREPROC_OPS.quadfixsize = 0;      % size of overscanstrip 0 =>
                                      % cunning guess
    PREPROC_OPS.replaceborder = 1;    % replace image border or not
    PREPROC_OPS.medianfilter = 0;     % size of medianfilter
    
  elseif nargin == 1 && isstruct(varargin{1})
    
    PREPROC_OPS = varargin{1};
    [filename,fpath] = inputimg;
    filename = fullfile(fpath,filename);
    
  elseif nargin == 0
    
    [filename,fpath] = inputimg;
    filename = fullfile(fpath,filename);
    PREPROC_OPS = typical_pre_proc_ops;
    PREPROC_OPS.quadfix = 2;          % number of overscan strips
    PREPROC_OPS.quadfixsize = 0;      % size of overscanstrip 0 =>
                                      % cunning guess
    PREPROC_OPS.replaceborder = 1;    % replace image border or not
    PREPROC_OPS.medianfilter = 0;     % size of medianfilter
    
  else
    
    error(['starcal2: wrong number of arguments: ',num2str(nargin)])
    
  end
  
  if length(filename) == 1 || filename == 0
    return
  else
    
    PREPROC_OPS.skip_dialogs = 0; % The star calibration
                                  % desperately needs time and
                                  % location meta data, so if these
                                  % are not produced by any
                                  % meta-data handling function
                                  % then prompt the user for these.
    [cal_image,img_head,obs] = inimg(filename,PREPROC_OPS);
    obs.png_header = img_head;
    obs.filename = filename;
    if max(cal_image(:)) <= 1 % In case the peak image intensity is
                              % less than one, we guess that the
                              % input image is in some 8-bit format
                              % that matlab/inimg cast-n-scale to
                              % between 0-1. Then this is most
                              % definitely not photon counts - this
                              % is assumed for a few noise level
                              % estimations. Therefore it is just
                              % as well to multiply the image with
                              % something. 
      cal_image = 1000*cal_image;
    end
  end
end

if ( isfield(obs,'optpar') )
  
  obs.optpar(~isfinite(obs.optpar)) = 0;
  optpar = obs.optpar;
  optmod = 1;
  if isfield(obs,'optmod')
    optmod = obs.optmod;
  elseif length(obs.optpar)>8
    optmod = obs.optpar(9);
  end
  
elseif ALIS_FITS
  
  optpar = guess_alis_optpar(obs);
  optmod = 3;
  optpar(~isfinite(optpar)) = 0;
  
elseif exist('your_guess_optpar','file')
  [optpar,optmod] = your_guess_optpar(obs);
else
  disp('You''d better make a function: your_guess_optpar.m')
  disp('That should give an array similiar to the output from:')
  disp('guess_alis_optpar.m')
  disp('For now using: optpar = [-1 1 0 0 0 0 0 0]')
  disp('Corresponding to ~45 deg fov and imaging in zenith.')
  optpar = [-1 1 0 0 0 0 0 0];
  optmod = 3;
end

[fp,filename,ext] = fileparts(filename);

SkMp.obs = obs;
% TODO: fix this in some good way.
if exist('PREPROC_OPS','var') && isfield(PREPROC_OPS,'StarCalResDir')
  SkMp.StarCalResDir = PREPROC_OPS.StarCalResDir; 
else
  SkMp.StarCalResDir = pwd; 
end
if exist('PREPROC_OPS','var') && isfield(PREPROC_OPS,'SAO')
  SkMp.SAO = PREPROC_OPS.SAO; 
end
stargui;

SkMp.obs = obs;
SkMp.obs.filename = filename;

