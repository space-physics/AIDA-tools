function varargout = ALIS_image_sequence(files,PO,OPS)
% ALIS_IMAGE_SEQUENCE - to display an ALIS image sequence as movie
%
% CALLNG:
%   OPS       = ALIS_image_sequence
%   M         = ALIS_image_sequence(files,PO,OPS)
%   imgstacks = ALIS_image_sequence(files,PO,OPS)
%   rgbstack  = ALIS_image_sequence(files,PO,OPS)
%   [I99,ImM,Ihists] = ALIS_image_sequence(files,PO,OPS)
%
% INPUTS:
%   indices2show - either array of image sequence numbers to
%                  display, or a triplett [first, step, last] or
%                  [first, last, step] with index to the first
%                  image to load the step to take to the next and
%                  the latest frame number to show. This means that
%                  one cannot display sequences of three arbitrary
%                  images - choose either 4 arbitrary and scrap the
%                  last.
%   Cams     - and array with the ALIS camera numbers to read
%              [1 x nC] where nC [1, 2, 3], if scalar only the
%              images from the corresponding camera is displayed,
%              if 2 then 2 images are diplayed side-by-side, if 3
%              then three images are displayed together with an
%              RGB-composited.
%   OPS      - options struct, with the default options returned
%              when ALIS_image_sequence is called without
%              arguments. Fields: 
%              OPS.loud = 0; Suppresses some willy-nilly output.
%              OPS.caxis = {'','',''}; If empty the intensity
%                   scale is automatic for each individual frame, if set
%                   to arrays with [ nImgs x 2 ] then that will be
%                   used for each corresponding image.
%              OPS.imsize = {[],[],[]}; Set to something if output
%                   images is to be resized
%              OPS.imdisplay = 1;   set to zero top suppress
%                   displaying - useful to increase speed when only
%                   intaxes is requested
%              OPS.shift = [0,0,0]; For shifting the image
%                   sequences relative to each other in index number
%              OPS.histmaxint - maximum intensity for intensity
%                   histogram, scalar, default is 8000.
%              OPS.filterkernel = {[],[],[]}; Set either field to
%                   a filter kernel for filtering the images before
%                   diplaying them.
%              OPS.outargtype = [ {'M'} | 'imgstack' | 'rgbimgstack' | 'intaxes']
%                   For M - Movie; imgstack - stack of the images from
%                   the cameras Cams, rgbimgstack for stack of
%                   RGB-composites, or intaxes for returning intensity
%                   ranges - the 99 percentile and the min-max intensity
%                   ranges.
%              OPS.savedir - path (full or relative) to directory
%                   displayed images should be saved in. (Upon
%                   which I cannot put!) Make sure write
%                   permissions exist. If directory does not exist
%                   it will be created. Defaults to empty <-> no
%                   saving, set to something if saving is desired,
%                   './' for present working directory.
%              OPS.savetype - file type to save file to
%                   [{'png'}|'jpg',any other imgwrite-able-filetype]
%                   - SEE imwrite for full list.
% Output:
%  OPS       - Default options struct, is returned if
%              ALIS_image_sequence is called without inpu
%  M         - Matlab movie structure, SEE MOVIE, getframe for
%              details.
%  imgstacks - Cell array with image stacks from the ALIS cameras
%              selected with Cams
%  rgbstack  - stack of RGB composite images made up of images from
%              selected cameras.
%  [I99,ImM] - Cell array with Intenisty arrays I99 is intensity
%              ranges image-by-image with 3% (Yup!) histogram
%              clipping ImM is intensity range min-Max
% 

% Copyright B Gustavsson 20101119 <bjorn@irf.se>
% This is free software, licensed under GNU GPL version 2 or later

% Default options:
dOPS.loud = 0;           % Just to make things less out-putty
dOPS.caxis = '';         % Intensity axeses, if left empty defaults to 'auto'
dOPS.imsize = {[]};      % Output image sizes, if empty no post-binning
dOPS.imdisplay = 1;      % 1 to plot images, zero to not.
dOPS.filterkernel = [];  % Kernel for linear image filtering
dOPS.outargtype = 'M';   % or 'imgstack' or 'rgbimgstack' or 'intaxes'
dOPS.savedir = '';       % Path to where to save image output
dOPS.histmaxint =  5000; % maximum histogram image intensity bin
dOPS.histminint =     0; % minimum histogram image intensity bin
dOPS.histClip =    0.01; % minimum histogram image intensity bin
dOPS.savetype = 'png';   % image format to save into
dOPS.videodir = '';      % 
% If no input arguments return the default option struct
if nargin == 0
  varargout = {dOPS};
  return
end
% If there is an options struct in the input merge the user options
% ontop of the defaults.
if nargin > 2
  dOPS = merge_structs(dOPS,OPS);
end
% If there is a savedir in the options by now make sure that it
% will exist:
if ~isempty(dOPS.savedir)
  if exist(dOPS.savedir,'dir') ~= 7
    try
      mkdir(dOPS.savedir)
    catch
      warning(['Could not create directory: ',dOPS.savedir])
      return
    end
  end
end

M = [];

%Using calibration values from Tromso data 2006, for 6730�, 7319� and 7774�
% calib = [0.5, 0.36, 0.85]
% Read the calibration factors for the event
%% calib = ALIS_get_alis_cal(vs.vmjs(vs.vsel),[1,2,3]);

iI = 1;
Int_ranges = zeros(size(files,1),2);
Int_perc = zeros(size(files,1),2);
Ihists = zeros(2048,size(files,1));
filtID = zeros(size(files,1),1);

for num = 1:size(files,1),
  if dOPS.loud
    disp(num)
  end
  
  % Read the ALIS image and scale to Rayleighs
  %[im,h,o] = inimg(files(num).name,PO);
  [im,h,o] = inimg(files(num,:),PO);
  filtID(iI) = o.filter;
  if ~isempty(dOPS.filterkernel)
    im = imfilter(im,dOPS.filterkernel,'replicate');
  end
  
  % If required do post-binning to 256 x 256
  if isempty(dOPS.caxis)
    Int_ranges(iI,:) = [min(im(:)) max(im(:))];
    Int_perc(iI,:) = ASK_auto_range(im, dOPS.histClip);
    if strcmp(dOPS.outargtype,'intaxes') & nargout > 2
      Ihists(:,iI) = hist(im(:),linspace(-200,24000,2048));
    end
  else
    Int_perc(iI,:) = dOPS.caxis(min(size(dOPS.caxis,1),iI),:);
    if strcmp(dOPS.outargtype,'intaxes') & nargout == 3
      Ihists(:,iI) = hist(im(:),linspace(-200,16000,2048));
    end
  end
  
  % [Hn,Hx] = histc(im(:),linspace(dOPS.histminint,dOPS.histmaxint,size(im,1)));
  if isempty(dOPS.histmaxint)
    cImg = ASK_bytscl(im{(1)},Int_perc(iI,1),Int_perc(iI,2),1);
  else
    [Hn] = histc(im(:),linspace(dOPS.histminint,dOPS.histmaxint,size(im,1)));
    cImg = [ASK_bytscl(im,Int_perc(iI,1),Int_perc(iI,2),1),repmat(Hn/max(Hn),1,10)];
  end
  if dOPS.imdisplay
    imagesc(cImg),axis xy
    % Decorations:
    title(['ALIS (',sprintf('%d',o.filter),'): ',datestr(o.time,'yyyy-mm-dd HH:MM:SS.FFF')],'fontsize',16);
    %ASK_print_dat(ASK_time_v(num,1),'HH:MM:SS.FFF');
    drawnow;
  end
  if ~isempty(dOPS.outargtype)
    switch dOPS.outargtype
     case 'M'
      set(gca,'xtick',[],'ytick',[])
      M(iI) = getframe(gcf);
     case 'imgstack'
      %disp('Here we should get images...')
      Im(:,:,iI) = im{i2};
     otherwise
      % Don't know what to do so do nothing.
    end
  end
  if ~isempty(dOPS.savedir)
    %disp(['writing current image to file: ',fullfile(dOPS.savedir,sprintf('%05d.%s',num,dOPS.savetype))])
    %imwrite(get(get(gca,'children'),'CData'),fullfile(dOPS.savedir,sprintf('%05d.dOPS.savetype',num)))
    imwrite(flipdim(cImg,1),fullfile(dOPS.savedir,sprintf('%05d.%s',num,dOPS.savetype)))
  end
  iI = iI+1;
  
end

switch dOPS.outargtype
 case 'M'
  varargout{1} = M;
 case 'imgstack'
  %disp('Here we should return images...')
  varargout{1} = Im;
 case 'rgbimgstack'
  varargout{1} = allRGB;
 otherwise
  if nargout > 0
    varargout{1} = Int_perc;
  end
  if nargout > 1
    varargout{2} = Int_ranges;
  end
  if nargout > 2
    varargout{3} = Ihists;
  end
  if nargout > 3
    varargout{4} = filtID;
  end
end


if isfield(dOPS,'stopinit') & dOPS.stopinit
  keyboard
end
