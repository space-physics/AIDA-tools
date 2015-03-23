function dOPS = ALIS_auto_overview(ops4AAO)
% ALIS_AUTO_OVERVIEW - automated fits data to png image conversion 
%  a Scrip for generating automatically scaled png-images from a
%  chunk of ALIS data, in addition single-emission animations from
%  each station will be made. The trick with this is that there is
%  an automatic intensity scaling that uses histogram clipping on
%  each image - those limits will then be filtered (local maximum
%  and low-pass) and used as time-varying intensity-limits. The
%  benefit with this is that periods of very bright aurora will be
%  mapped between black and white (0-1, 0-255, whatever) without
%  completely pushing periods with fainter aurora down into all
%  black and darkest grays. To display the actual intensity scale
%  the histogram of absolute intensities is displayed thermometer
%  style on the right edge of the images.
%
% Calling:
%   dOPS = ALIS_auto_overview
%   dOPS = ALIS_auto_overview(ops4AAO)
%   dOPS = ALIS_auto_overview(-1)
% Input:
%   ops4AAO - struct with fields controlling the behaviour of the
%             function
%   -1      - any non-struct input actually, to get the default
%             struct out without any further processing.
% Output:
%   dOPS - struct with the default parameters:
%       .MovieBaseName  = 'overview' - name for movie file, to this
%                         station, filter and date information will
%                         be appended.
%       .medianfilter   = 0 region size for image filtering, > 0
%                         2-D median filtering, < 0 wiener2
%                         filtering see also INIMG.
%       .colormap       = bone - colour map, either nx3 double
%                         array with rgb-values 0-1, or string
%                         with name of function returning such
%                         a colourmap-array.
%       .figureposition = [1138 464 560 510]; default position of
%                         figure window [x0 y0 dx dy] (pixels)
%       .ffc            = 1; Flat-field-correction matrix, see:
%                         FFC_CORRECTION2 
%       .BaseSaveDir    = '/home/bjorn/tmp/'; path to the directory
%                         where converted images will be saved,
%                         full or relative path.
%       .histClip       = 0.003; fraction of intensities to clip
%                         when mapping the image to 0-1.

%   Copyright ? 2012 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

%% Struct with default parameters:
dOPS.MovieBaseName  = 'overview';
dOPS.medianfilter   = 0;
dOPS.colormap       = bone;
dOPS.figureposition = [1138 464 560 510];
dOPS.ffc            = 1;
dOPS.BaseSaveDir    = '/home/bjorn/tmp/';
dOPS.histClip       = 0.003;

% If there is input argument and that is a struct 
if nargin > 0 & isstruct(ops4AAO)
  % then merge that ontop of the default ones
  dOPS = merge_structs(dOPS,ops4AAO);
elseif nargin > 0
  % if the input argument is not a struct (supposedly with options)
  % then simply return the default struct
  return
end
% that way the function will continue below with the default
% parameters if there is no input argument...



%% 0 pre-amblings
% Put up a figure with predefined size:
figure('position',dOPS.figureposition)
%%
% Make its colormap grayish, bone is neater to the eye:0
colormap(dOPS.colormap)
%%
% Preprocessing options for reading and preparing ALIS data:
PO = typical_pre_proc_ops('alis');
PO.ffc = [];%dOPS.ffc;
PO.medianfilter = dOPS.medianfilter; % Set this to 3 in case image filtering is needed
PO.BE = 1;                           % This is the setting except for a brief
                                     % period in the late 90s or early 2000s...
if isfield(dOPS,'optpar')
  PO.optpar = dOPS.optpar;
end
if isfield(dOPS,'interference_level')
  PO.interference_level = dOPS.interference_level;
end
%%
% Only look for images from imaging stations...
% ...skip calibration data?
stn_keys = {'\*K.fits','\*M.fits','\*S.fits','\*T.fits','\*A.fits','\*N.fits','\*O.fits','\*B.fits'};

% Process the data station by station:
for iS = 1:length(stn_keys),
  %% 1 Search for fits-files below current working directory
  [~,q] = my_unix(['find ./ -name ',stn_keys{iS}]);
  if ~isempty(q) % then we actually have data from that station
    % Sort the file-names in sequence of time...
    q = sortrows(q(1:end-1,:));
    
    % Read one image to get the observation date...
    [d,h,o] = inimg(q(1,:),PO);
    
    % Prepar to run the image-sequence function:
    ops4imseq = ALIS_image_sequence;
    ops4imseq.histClip = 0.003;       % Only clip this hard
    ops4imseq.outargtype = 'intaxes'; % First we want the intensity
                                % limits out
    
    %% 2 Get the intensity limits - as well as the intensity histogram
    % and the filter sequence:
    [I99,ImM,Ihists,filtIdB] = ALIS_image_sequence(q,PO,ops4imseq);
    
    % Get the filters that are used...
    uFilts = unique(filtIdB);
    for i1 = 1:length(uFilts),
      % ...and loop over each filter
      if size(I99(filtIdB==uFilts(i1),:),1) > 15
        % only do the data conversion to png-files if there are
        % more than 5 images with the current filter
        
        %% 3 Max and low-pass filter the intensity limits.
        Im99 = maxfilt1(I99(filtIdB==uFilts(i1),:),5);
        fIm99 = filtfilt([.25 .75 1 .75 .25]/3,1,Im99);
        
        %% 4 prepare for the fits to png-image conversion...
        ops4imseq.outargtype = 'M'; % get a matlab-movie back
        ops4imseq.caxis = fIm99;    % set the filtered intensity limit to
                                    % be the hard intensity limits to use.
        
        %% 
        % Set the output directory to where to print the png images,
        % that is one directory per station and filter per date:
        ops4imseq.savedir = fullfile(dOPS.BaseSaveDir,...
                                     sprintf('ALIS-%s-%d-%s',...
                                             stn_keys{iS}(3),uFilts(i1),datestr(o.time,'yyyy-mm-dd')));
        %% 5, run the image conversion:
        [Mov] = ALIS_image_sequence(q(filtIdB==uFilts(i1),:),PO,ops4imseq);
        %% 6, write the movie to an avi-file.
        if ~isempty(Mov)
          moviename = [dOPS.MovieBaseName,'-',sprintf('%s-%d-%s',stn_keys{iS}(3),uFilts(i1),datestr(o.time,'yyyy-mm-dd')),'.avi'];
          movie2avi(Mov,fullfile(ops4imseq.savedir,moviename))
        else
          moviename = [dOPS.MovieBaseName,'-',sprintf('%s-%d-%s',stn_keys{iS}(3),uFilts(i1),datestr(o.time,'yyyy-mm-dd')),'.avi'];
          disp(['WARNING: The movie : ',moviename,' is empty!'])
          disp(['even though it should kind of contain: ',num2str(sum(double(filtIdB==uFilts(i1)))),' frames, peculiar...'])
        end
      end
      
    end
    
  end
  
end
