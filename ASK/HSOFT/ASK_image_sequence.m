function varargout = ASK_image_sequence(indices2show,Cams,OPS)
% ASK_IMAGE_SEQUENCE - to display an ASK image sequence as movie, and
% three keograms in one figure.
%
% CALLNG:
%   OPS       = ASK_image_sequence
%   M         = ASK_image_sequence(indices2show,Cams,OPS)
%   imgstacks = ASK_image_sequence(indices2show,Cams,OPS)
%   rgbstack  = ASK_image_sequence(indices2show,Cams,OPS)
%   [I99,ImM,Ihists] = ASK_image_sequence(indices2show,Cams,OPS)
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
%   Cams     - and array with the ASK camera numbers to read
%              [1 x nC] where nC [1, 2, 3], if scalar only the
%              images from the corresponding camera is displayed,
%              if 2 then 2 images are diplayed side-by-side, if 3
%              then three images are displayed together with an
%              RGB-composited.
%   OPS      - options struct, with the default options returned
%              when ASK_image_sequence is called without
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
%              ASK_image_sequence is called without inpu
%  M         - Matlab movie structure, SEE MOVIE, getframe for
%              details.
%  imgstacks - Cell array with image stacks from the ASK cameras
%              selected with Cams
%  rgbstack  - stack of RGB composite images made up of images from
%              selected cameras.
%  [I99,ImM] - Cell array with Intenisty arrays I99 is intensity
%              ranges image-by-image with 3% (Yup!) histogram
%              clipping ImM is intensity range min-Max
% 

% Copyright B Gustavsson 20101119 <bjorn@irf.se>
% This is free software, licensed under GNU GPL version 2 or later

global vs

% Default options:
dOPS.loud = 0;                  % Just to make things less out-putty
dOPS.caxis = {'','',''};        % Intensity axeses, if left empty defaults to 'auto'
dOPS.imsize = {[],[],[]};       % Output image sizes, if empty no post-binning
dOPS.imdisplay = 1;             % 1 to plot images, zero to not.
dOPS.shift = [0,0,0];           % Index shift between concurrent images
dOPS.filterkernel = {[],[],[]}; % Kernel for linear image filtering
dOPS.outargtype = 'M';          % or 'imgstack' or 'rgbimgstack' or 'intaxes'
dOPS.savedir = '';              % Path to where to save image output
dOPS.histmaxint = 8000;         % maximum histogram image intensity bin
dOPS.histminint =    0;         % minimum histogram image intensity bin
dOPS.DoCumHist =     1;         % Use cumulative histogram to indicate intensity scaling
dOPS.savetype = 'png';          % image format to save into
dOPS.videodir = '';             % 
dOPS.keodir   = '';             % 
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

ASK_v_select(Cams(1),'quiet');% Select one camera here just in case
                              % we need to build the index2show array


% This is a cunning way of letting the indices2show be either a set
% of image indices to display ([1,2,3,12:321, 475, 1234,17]) or a
% triplet making up a [i2first,i2last,iStep] or  [i2first,iStep,i2last]
if length(indices2show) == 3
  indices2show = [indices2show(1),sort(indices2show(2:3))];
  indices2show = indices2show(1):indices2show(2):indices2show(3);
elseif isempty(indices2show)
  indices2show = 1:vs.vnl(vs.vsel);
end
nelem = length(indices2show); 

%Using calibration values from Tromso data 2006, for 6730�, 7319� and 7774�
% calib = [0.5, 0.36, 0.85]
% Read the calibration factors for the event
calib = ASK_get_ask_cal(vs.vmjs(vs.vsel),[1,2,3]);

iI = 1;
for i1 = length(Cams):-1:1,
  Int_ranges{i1} = zeros(nelem,2);
  Int_99perc{(i1)} = zeros(nelem,2);
end
cmap = colormap;

ASK_v_select(Cams(1),'quiet');

Keo1h = [];
if ~isempty(dOPS.keodir)
  Keo1h = zeros(vs.vnl(vs.vsel),vs.dimx(vs.vsel));
  Keo2h = zeros(vs.vnl(vs.vsel),vs.dimx(vs.vsel));
  Keo1v = zeros(vs.vnl(vs.vsel),vs.dimy(vs.vsel));
  Keo2v = zeros(vs.vnl(vs.vsel),vs.dimy(vs.vsel));
else
  dOPS
end

for num = indices2show,
  if dOPS.loud
    disp(num)
  end
  %cImg = 0;
  for iCam = length(Cams):-1:1,  % Read the images for current time
    % Set the current camera
    if length(Cams) > 1
      ASK_v_select(Cams(iCam),'quiet');
    end
    % Read the ASK#i1 image and scale to Rayleighs
    im{iCam} = ASK_read_v(num+dOPS.shift(Cams(iCam)),[],[],[],dOPS)*calib(Cams(iCam))/vs.vres(vs.vsel);
    if ~isempty(dOPS.filterkernel{iCam})
      im{iCam} = imfilter(im{iCam},dOPS.filterkernel{iCam},'replicate');
    end
    
    % If required do post-binning to 256 x 256
    if ~isempty(dOPS.imsize{Cams(iCam)}) & ~all(size(im{Cams(iCam)})==dOPS.imsize{Cams(iCam)})
      im{iCam} = ASK_binning(im{iCam},size(im{iCam})./dOPS.imsize{11});
    end
    if isempty(dOPS.caxis{iCam})
      Int_ranges{(iCam)}(iI,:) = [min(im{(iCam)}(:)) max(im{(iCam)}(:))];
      Int_99perc{(iCam)}(iI,:) = ASK_auto_range(im{(iCam)}, 0.01);
      if strcmp(dOPS.outargtype,'intaxes') & nargout == 3
        Ihists{iCam}(:,iI) = hist(im{iCam}(:),linspace(-200,16000,2048));
      end
    else
      Int_99perc{(iCam)}(iI,:) = dOPS.caxis{(iCam)}(min(size(dOPS.caxis{(iCam)},1),iI),:);
      if strcmp(dOPS.outargtype,'intaxes') & nargout == 3
        Ihists{iCam}(:,iI) = hist(im{iCam}(:),linspace(-200,16000,2048));
      end
    end
    if ~isempty(Keo1h)
      Keo1h(iI,:) = mean(im{iCam}(end/2+[-3:3],   :),1);
      Keo2h(iI,:) = mean(im{iCam}(end/2+[-3:3]-20,:),1);
      Keo1v(iI,:) = mean(im{iCam}(:,end/2+[-3:3]   ),2);
      Keo2v(iI,:) = mean(im{iCam}(:,end/2+[-3:3]-20),2);
    end
    
  end
  
  % Image displaying
  if length(Cams) == 1 % one camera just display!
    %if exist('imhist','file') == 2
    %  [Hn,Hx] = imhist(ASK_bytscl(im{1}(:),0,dOPS.histmaxint,1),size(im{1},1));
    %else
    [Hn,Hx] = histc(im{1}(:),linspace(dOPS.histminint,dOPS.histmaxint,size(im{1},1)));
    %end
    if isempty(dOPS.histmaxint)
      cImg = ASK_bytscl(im{(1)},Int_99perc{(1)}(iI,1),Int_99perc{(1)}(iI,2),1);
    else
      % [Hn,Hx] = histc(im{1}(:),linspace(dOPS.histminint,dOPS.histmaxint,size(im{1},1)));
      [Hn] = histc(im{1}(:),linspace(dOPS.histminint,dOPS.histmaxint,size(im{1},1)));
      if dOPS.DoCumHist
	Hn = flipud(cumsum(flipud(Hn)));
      end
      cImg = [ASK_bytscl(im{(1)},Int_99perc{(1)}(iI,1),Int_99perc{(1)}(iI,2),1),repmat(Hn/max(Hn),1,10)];
    end
    if dOPS.imdisplay
      imagesc(cImg),axis xy
      % Decorations:
      title(['ASK: ',ASK_dat2str(ASK_time_v(num,1),'yyyy-mm-dd HH:MM:SS.FFF')],'fontsize',16);
      %ASK_print_dat(ASK_time_v(num,1),'HH:MM:SS.FFF');
      drawnow;
    end
  elseif length(Cams) == 2
    %cImg = [ASK_bytscl(im{Cams(1)},Int_99perc{(1)}(iI,1),Int_99perc{(1)}(iI,2),1),ASK_bytscl(im{(2)},Int_99perc{(2)}(iI,1),Int_99perc{Cams(2)}(iI,2),1)]*size(cmap,1);
    cImg = [ASK_bytscl(im{Cams(1)},Int_99perc{(1)}(iI,1),Int_99perc{(1)}(iI,2),1),ASK_bytscl(im{(2)},Int_99perc{(2)}(iI,1),Int_99perc{(2)}(iI,2),1)]*size(cmap,1);
    if dOPS.imdisplay
      try
        imshow(cImg,cmap);
      catch
        imagesc(cImg)
      end
      axis xy;
      % Decorations:
      title(['ASK: ',ASK_dat2str(ASK_time_v(num,1),'yyyy-mm-dd HH:MM:SS.FFF')],'fontsize',16);
      %title(['ASK: ',ASK_dat2str(ASK_time_v(num,1),'yyyy-mm-dd')],'fontsize',16);
      %ASK_print_dat(ASK_time_v(num,1),'HH:MM:SS.FFF');
      drawnow;
    end
  else
    % Olden way, separate intensity adjustment, prone to false
    % changes in hue:
    imB = ASK_bytscl(im{1},Int_99perc{1}(iI,1),Int_99perc{1}(iI,2),1);
    imG = ASK_bytscl(im{2},Int_99perc{2}(iI,1),Int_99perc{2}(iI,2),1);
    imR = ASK_bytscl(im{3},Int_99perc{3}(iI,1),Int_99perc{3}(iI,2),1);
    %imHSV = rgb2hsv(dOPS.Ints2gray(3)*im{3},dOPS.Ints2gray(2)*im{2},dOPS.Ints2gray(1)*im{1});
    %imHSV(:,:,3) = ASK_bytscl(imHSV(:,:,3),Int_99perc{3}(iI,1),Int_99perc{3}(iI,2),1);
    %[imR,imG,imB] = hsv2rgb(imHSV);
    cImg(:,:,1) = [[1*imR,1*imG];[1*imB,imR]];
    cImg(:,:,2) = [[1*imR,1*imG];[1*imB,imG]];
    cImg(:,:,3) = [[1*imR,1*imG];[1*imB,imB]];
    if dOPS.imdisplay
      %imshow(cImg);axis xy
      imagesc(cImg);axis xy
      % Decorations:
      title(['ASK: ',ASK_dat2str(ASK_time_v(num,1),'yyyy-mm-dd HH:MM:SS.FFF')],'fontsize',16);
      %title(['ASK: ',ASK_dat2str(ASK_time_v(num,1),'yyyy-mm-dd')],'fontsize',16);
      %ASK_print_dat(ASK_time_v(num,1),'HH:MM:SS.FFF');
      drawnow;
    end
  end
  if ~isempty(dOPS.outargtype)
    switch dOPS.outargtype
     case 'M'
      set(gca,'xtick',[],'ytick',[])
      M(iI) = getframe(gcf);
     case 'imgstack'
      %disp('Here we should get images...')
      for i2 = 1:length(Cams),
        Im{i2}(:,:,iI) = im{i2};
      end
     case 'rgbimgstack' 
      allRGB{iI} = cImg;
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

if ~isempty(Keo1h)
  Keo1h = Keo1h(1:iI-1,:);
  Keo2h = Keo2h(1:iI-1,:);
  Keo1v = Keo1v(1:iI-1,:);
  Keo2v = Keo2v(1:iI-1,:);
  save(fullfile(dOPS.keodir,[dOPS.ffilename,'-H-00']),'Keo1h');
  save(fullfile(dOPS.keodir,[dOPS.ffilename,'-H-20']),'Keo2h');
  save(fullfile(dOPS.keodir,[dOPS.ffilename,'-V-00']),'Keo1v');
  save(fullfile(dOPS.keodir,[dOPS.ffilename,'-V-20']),'Keo2v');
  disp('===================================================')
  disp(['Saved files: ',fullfile(dOPS.keodir,[dOPS.ffilename]),' just fine!'])
  disp('===================================================')
else
  dOPS
  whos Keo*
  disp('Was not saved at all...')
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
    varargout{1} = Int_99perc;
  end
  if nargout > 1
    varargout{2} = Int_ranges;
  end
  if nargout > 2
    varargout{3} = Ihists;
  end
end


if isfield(dOPS,'stopinit')
  keyboard
end
