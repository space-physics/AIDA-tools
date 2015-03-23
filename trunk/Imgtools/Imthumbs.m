function Ops = Imthumbs(inFiles,spp_layout,ops)
% IMTHUMBS - display thumbnails gallery of list of images 
%  IMMTHUMBS loads and downsamples a given list of image files and
%  displays them in scrollsubplots, then after browsing the user
%  can select individual images to load to the workspace or display
%  in an separate figure where the image can be studied further.
%  The current figure will be used for the thumbnail gallery, and
%  another figure will be created for the full-image displays.
%  
% Calling:
%   Imthumb([inFiles],[spp_layout],[ops])
%   ops = Imthumbs
% Input:
%   inFiles   - files with imreadable images, either an array of 
%               structs as returned by dir, or a string array. The
%               files should be in the current directory or the
%               filenames has to be full or relative filenames to 
%               files in other directories. If left out Imthumb
%               will look for image files in the current
%               directory.
%  spp_layout - optional array with subplot layout of the thumbnail
%               gallery [nRow, nCols] will display nRows x nCols
%               number of images in nRows with nCols number of
%               subplots, scrollsubplot is used to extend the
%               figure canvas. If spp_layout is not given the
%               default values of [3,3] is used.
%  ops        - optional struct with options for Imthumb. The
%               default options struct is returned when Imthumbs is
%               called with an output argument and without input
%               arguments. The current option fields are:
%               .LineWidths - default linewidth: 1
%               .LineStyles - [{ '-' }|'--'|'-.'|':'|'.']
%               .LineColor  - [{ 'r' }|'b'|'g'|'c'|'m'|'k'|[R,G,B]]
%               .ImShowFcn  - [{ 'imagesc' }| 'imshow' ]
%               .ImToolFcn  - [{ 'imthumbImTool'}| 'imtool' ]
%               .fontsizes  - default fontsize: 12
%               .lutbar     - [{'on'}| 'off'] colormaps in a
%                       toolbar ('on') or a menu ('off')
%               .colorbar   - [ {'hist'} | 'always'|'off'] to show
%                       a colorbar next to the full-scale
%                       gray-scale images, 'hist' for when plotting
%                       intensity histograms.
%               .ThumbnailTitles = [{ 'off' }| 'on' ]
%               .ThumbnailTargetSize = 256; Target size for small
%                       dimension size of thumbnail, change this
%                       will not change appearance much.
%               .Waitbar    - [ {'on'} | 'off' ] to show a waitbar
%                       or not during the creation of the thumbnail
%                       gallery.
%
% 
%  Each thumbnail image has a pop-up menu with image information
%  and items for loading the full image to the workspace, or
%  display it in the full-view figure.
%
%  Example:
%   % Move to where some images are:
%   cd /usr/local/MATLAB/R2013a/toolbox/images/imdemos
%   % (If you don't have the Image proc just pick another directory
%   % of yours...)
%   % list some images of interest:
%   qP = dir('*.png');
%   qT = dir('*.tif*');
%   % Create a 3x3 scrollable thumbnail gallery:
%   Imthumbs([qP;qT])
%
%   %  change to show all images, also adjust the linewidths: 
%   ops = Imthumbs;
%   ops.LineWidths = 2;
%   Imthumbs([],[3,4],ops)
% 
% From there basic information about the image and options to
% display the full image and to load the image into a named
% workspace variable can be reached by pushing the right mouse
% button over the image of interest. In the "Full-scale view"
% figure line and column cuts can be selected with the left mouse
% button ('normal'), the middle mouse button ('extend') gives
% intensity and cumulative intensity histogram displays and after
% right-button clicks ('alt') a zoom-axes is shown (in which the
% left and right mouse buttons zooms out and in respectively),
% lastly for RGB images the line cuts will be plotted
% as HSV values after double-clicking ('open'). 
%
% This tool require the SCROLLSUBPLOT function FEX-ID: 7730, and
% additional functionality is gained with LUTBAR function, FEX-ID: 9137

%   Copyright © 20140122 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


Dops.LineWidths    = 1;   %  [0.5, { 1 }, 2, 3, ...]
Dops.LineStyles    = '-'; %  [{ '-' },'--','-.',':','.']
Dops.LineColor     = 'r';  %  [{ 'r' },'b','g','c','m','k',[R,G,B]]
Dops.ImShowFcn     = 'imagesc'; % imshow
Dops.ImToolFcn     = 'imthumbImTool'; % imtool
Dops.ImTzoomaxsize = 0.15; % fraction of image size
Dops.ImTzoom2nrpix = 20;   % side-length of image to zoom into [pixels]
Dops.fontsizes     = 12;
Dops.colorbar      = 'hist'; % [{'hist'}|'always','off']
Dops.Waitbar       = 'on'; % 'off'
Dops.lutbar        = 'on'; % 'off'
Dops.ThumbnailTitles = 'off'; % or 'on'
Dops.ThumbnailTargetSize = 256; % Target size for small dimension size

if nargout && nargin == 0
  Ops = Dops;
  return
elseif nargin > 2 && ~isempty(ops)
  Dops = merge_structs(Dops,ops);
end

if strcmpi(Dops.Waitbar,'on')
  wbh = waitbar(0,'Working on...');
end
if ( nargin < 1 || isempty(inFiles) )
  inFiles = get_im_names;
end

if nargin < 2 || isempty(spp_layout)
  % If no spp_layout given, use the default:
  spp_layout = [3,3];
end

colormap(gray)
fig_overviews = gcf;
set(fig_overviews,'name','Thumbnail gallery')
if ~strcmpi(Dops.ImToolFcn,'imtool')
  fig_full = figure('name','Full-scale view'); % pos and such tbd
else
  fig_full = 0;
end
figure(fig_overviews)

wpwd = pwd; % filesnames have to be full or relative path from
            % current directory, to make files loadable from
            % wherever we prepend the file with the current working
            % directory
if isstruct(inFiles(1))
  inFiles = char(inFiles.name);
end
%% Loop over the image files
for i1 = 1:size(inFiles,1),
  %% 0 create scrollsubplots:
  if strcmpi(Dops.Waitbar,'on')
    waitbar(i1/size(inFiles,1),wbh,['Working on file: ',strtrim(inFiles(i1,:))])
  end
  scrollsubplot(spp_layout(1),spp_layout(2),i1)
  %% 1 Read the images:
  imfo = imfinfo(strtrim(inFiles(i1,:)));
  if strcmp(imfo(1).ColorType,'indexed') % Then we have an indexed image
    if length(imfo) > 1
      [im,cmap] = imread(strtrim(inFiles(i1,:)),1);
    else
      [im,cmap] = imread(strtrim(inFiles(i1,:)));
    end
    im = ind2rgb(im,cmap);
  else
    if length(imfo) > 1
      [im] = imread(strtrim(inFiles(i1,:)),1);
    else
      [im] = imread(strtrim(inFiles(i1,:)));
    end
  end
  namestr = strtrim(inFiles(i1,:));
  namestr4load = fullfile(wpwd,namestr);%strtrim(inFiles(i1,:));
  imfo = str2strarr(imfo(1));
  
  % determine suitable downsampling factor, making the smallest
  % thumbnail dimension just larger than 256 (the default number) pixels...
  pixStep = max(1,min(floor(size(im(:,:,1))/Dops.ThumbnailTargetSize)));
  if length(size(im)) > 2
    im = im(1:pixStep:end,1:pixStep:end,1:3); % ...and downsample
  else
    im = im(1:pixStep:end,1:pixStep:end); % ...and downsample
  end
  if strcmpi(Dops.ImShowFcn,'imagesc')
    imagesc(im),set(gca,'xtick',[],'ytick',[])
  else
    imshow(im),set(gca,'xtick',[],'ytick',[])
  end
  if strcmpi(Dops.ThumbnailTitles,'on')
    title(strtrim(inFiles(i1,:)),'interpreter','none')
  end
  
  %% 2 Prepare uicontextmenu contents
  % strings for callbacks loading image to workspace as a named
  % variable (Im001, Im002,...) 
  assignstr = ['Im',sprintf('%03d',i1),' = imread(''',namestr4load,''');'];
  % and display in the full-view figure
  dispstring = ['imthumb_load_n_show(''',sprintf(namestr4load),''',',num2str(fig_full),')'];
  
  % ...and strings for the menu lables:
  hlbload = ['Load image as: Im',sprintf('%03d',i1)];
  hlbshow = 'Show full image';
  
  %% 3 Create the uicontextmenu:
  hcmenu = uicontextmenu;
  uimenu(hcmenu, 'Label', namestr );
  uimenu(hcmenu, 'Label', hlbshow, 'Callback',dispstring );
  uimenu(hcmenu, 'Label', hlbload, 'Callback',assignstr );
  for iHeader = 1:size(imfo,1),
    if iHeader == 1
      uimenu(hcmenu, 'Label', imfo(iHeader,:),'Separator','on');
    else      
      uimenu(hcmenu, 'Label', imfo(iHeader,:));
    end
  end
  hlines = findall(gca,'Type','image');
  set(hlines,'uicontextmenu',hcmenu);
  
end
if strcmpi(Dops.Waitbar,'on')
  close(wbh)
end
set(gcf,'userdata',Dops)
function outstr = str2strarr(iminfo)
% STR2STRARR - subfunction for making the IMFINFO struct into a
% neatly displayable string
% 
% Calling
%   outstr = str2strarr(iminfo)


fieldnms = fieldnames(iminfo(1));

outstr = 'Image Info:';
for iFields = 2:length(fieldnms),
  
  if ~isempty(iminfo(1).(fieldnms{iFields}))
    if ischar(iminfo(1).(fieldnms{iFields}))
      outstr = char(outstr,sprintf('%s:\t\t%s\n',fieldnms{iFields},iminfo(1).(fieldnms{iFields})));
    elseif ( isnumeric(iminfo(1).(fieldnms{iFields})) && ...
             all( rem(iminfo(1).(fieldnms{iFields})(:),1) == 0 ) )
      outstr = char(outstr,sprintf('%s:\t\t%d \n',fieldnms{iFields},iminfo(1).(fieldnms{iFields})));
    elseif isnumeric(iminfo(1).(fieldnms{iFields}))
      outstr = char(outstr,sprintf('%s:\t\t%f \n',fieldnms{iFields},iminfo(1).(fieldnms{iFields})));
    end
  end
  
end

outstr = outstr(:,1:min(100,size(outstr,2)));

function ImFiles = get_im_names
% GET_IM_NAMES Get the names of all images in a directory


D = dir;

iIm = 0;
 

% Go through the directory list
CF = cell(size(D));
for iD = 1:length(D)
  % Check if file is a supported image type
  [pth,name,ext] = fileparts(D(iD).name); %#ok<*ASGLU>
  if  ( ~D(iD).isdir && ...
        ~isempty(ext) && ...
        (any(strcmpi(ext, {'.bmp', ...
                        '.fits',...
                        '.jpeg',...
                        '.jpg', ...
                        '.pbm', ...
                        '.pgm', ...
                        '.png', ...
                        '.ppm', ...
                        '.ras', ...
                        '.tif', ...
                        '.tiff'}))) )
% Encountered some problems with IMREAD on multi-frame gif-files so removed them from automatic listing %'.gif', ...
    iIm = iIm + 1;
    CF{iIm} = D(iD).name;
    % ImFiles(iIm,1:length(D(iD).name)) = D(iD).name;
  end
end
ImFiles = char(CF{1:iIm});

function S_out = merge_structs(S1,S2)
% MERGE_STRUCTS - Merge all fields of S2 into S1.
%   


S_out = S1;

fields2 = fieldnames(S2);
for curr_field = fields2(:)',
  
  S_out = setfield(S_out,curr_field{:},getfield(S2,curr_field{:}));
  
end
