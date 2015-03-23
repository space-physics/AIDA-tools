function [keos,imstack,timeV] = ASK_keogram_overlayed(fir,las,ste,shft,width,x0,y0,angle,OPS)
% ASK_KEOGRAM_OVERLAYED - to plot an overlayed keogram, ASK images, and
% three keograms in one figure.
%
% CALLING:
%   OPS = ASK_keogram_overlayed;
%   [keo,imstack,timeV] = ASK_keogram_overlayed(fir,las,ste,shft,width,x0,y0,angle,OPS);
% INPUTS:
%   fir      - first image number 
%   las      - last image number 
%   ste      - frame step 
%   shift    - shift of images with respect to each other ([0,0,0] if there is no shift), 
%   width    - width of the column that is used for creating the keogram, 
%   x0, y0   - central pixles of the keogram cut, 
%   angle    - angle of the cut, where 0 is a horizontal cut and 90
%              vertical. 
%
%   OPS      - Struct with options controlling image preprocessing,
%              and the layout of the plot. Default options are
%              returned when ASK_keogram_overlayed is called
%              without input arguments:
% 
% The nicest keograms are created from appr. 1000 frames.
% 
% FEATURES:
% * If data is not calibrated this routine will crash!
% * Before caling this function ASK meta-data has to be read in
%   with read_vs! 
% * If the data is 512x512 pixels, the images will first be binned to
%   256x256 pixels
%
%
% The nicest keograms are created from appr. 1000 frames.
% WARNING: If data is not calibrated this routine will crash!
% First of all the ASK meta-data has to be read in with read_vs!
% If the data is 512x512 pixels, the images will first be binned to
% 256x256 pixels
%

%   name     - the name of the resulting ps-file 
%
% Optional arguments:
%   rad      - plots the radar data for the period instead of the ASK
%              images. Which data to read in
%              is hardcoded in this script.
%   bkg      - background to remove from [ASK1,ASK2,ASK3]
%   one      - Only one ASK image is plotted in the second panel
%              (overlay of ASK1,ASK2 and ASK3)
%   dist     - Puts distance on the y-axis in km (set up for ASK data)

global vs


dOPS.loud = 0;  % Set to one to possibly get current image number
                % and display of currently read image.
dOPS.quiet = 0; % Set to 1 to suppress the waitbar
dOPS.filtertype = {'none'}; % Set to cell array of filters to use
                            % when reading images: {'sigma','median'}
dOPS.filterArgs = {}; % Set to cell array of cell arrays with
                      % filter arguments: {{[3,3]},{[3,5],'symmetric'}}
dOPS.rad = [];  % Seems unused to me.
dOPS.bkg = [];  % set to [1 x 3] or [3 x 1] array of background
                % intensities to remove from the images
dOPS.oneImg = []; % Set to camera number to only plot images from
                  % that camera in the row of images, if set to
                  % other number (4) only the RGB composite is shown
dOPS.dist = [];   % not yet implemented
dOPS.subplot4imgs = [5,7,8]; % Subplot set up for the image-row:
                             % defaults to figure with five rows,
                             % image-row will have 7 columns,
                             % images will start with subplot #8 -
                             % first subplot in second row from the
                             % top
dOPS.subplot4RGBkeo = [5,1,1];  % Subplot row for RGB-composite keogram
dOPS.subplot4ASK1keo = [5,1,3]; % Subplot row for ASK-1 keogram
dOPS.subplot4ASK2keo = [5,1,4]; % Subplot row for ASK-2 keogram
dOPS.subplot4ASK3keo = [5,1,5]; % Subplot row for ASK-3 keogram
dOPS.imrowFontsize = 12;        % Fontsize for time-label of images.

% If no input arguments
if nargin == 0
  % return the default options
  keos = dOPS;
  % and exit
  return
end
% If there is an options structure in the inputs merge that one
% over the default one:
if nargin > 8
  dOPS = merge_structs(dOPS,OPS);
end

% Set the image size to reduce to:
imsiz = 128;

% Number of time-steps to read data for:
nelem = (las - fir)/ste + 1;

% allocate arrays for the keograms
keos{1} = zeros(256,nelem);
keos{2} = zeros(256,nelem);
keos{3} = zeros(256,nelem);

CurrFig = gcf;

if ~dOPS.quiet
  wbh = waitbar(0,'Making keograms, hold on...');
end

% pixel coordinates of rotated cut is calculated here
angle = angle*pi/180;
% This is hard-coded for images with size 256x256 - after
% downsampling...
x = [1:256]-128;  % Vertical strip 
if x0 == 128 & y0 == 128
  x = x/max([cos(angle),sin(angle)]); % scaled to be between 1-256
                                      % after rotation
end
y = -width/2:width/2;   % with horizontal width
[x,y] = meshgrid(x,y);  % all 2-D coordinates in it
X = [(x)*cos(angle)+(y)*sin(-angle)+x0]; % The 2-D strip 
Y = [(x)*sin(angle)+(y)*cos(angle)+y0];  % rotated

% for iCam = 1:3,
for iCam = 1:3,
  i1 = 1;
  ASK_v_select(iCam,'quiet'); % Set current camera
  for num = fir:ste:las
    if dOPS.loud
      disp(num)
    end
    % Read the three current images
    im{iCam} = ASK_read_v(num+shft(iCam),[],[],[],dOPS); % Read the current ASK image
    time_w(i1,:) = ASK_indx2datevec(num);                % Get its time
    % If required do post-binning to 256 x 256
    if all([vs.dimx(vs.vsel) vs.dimy(vs.vsel)] == [512 512])
      im{iCam} = ASK_binning(im{iCam},[2,2]);
    end
    
    % Rotate images and stuff the averaged intensities into the keograms:
    keos{iCam}(:,i1) = mean(interp2(im{iCam},X,Y,'cubic',0));
    
    if dOPS.loud
      % Display current image
      im{iCam} = img_rot(im{iCam},-(angle-90),x0,y0,'*spline',0);
      imagesc(im{iCam}),axis xy,drawnow
    end
    i1 = i1+1;
    if ~dOPS.quiet
      waitbar((num-fir)/(las-fir)/3+1/3*(iCam-1),wbh);
    end
    
  end
  
end

if ~dOPS.quiet
  waitbar(1,wbh,'Wrapping, done real soon now!');
end
% Alpha-trimm the intensity ranges
ran1 = ASK_auto_range(keos{1}, 0.01);
ran2 = ASK_auto_range(keos{2}, 0.01);
ran3 = ASK_auto_range(keos{3}, 0.01);
% Set the lower to 0 -> giving ranges between 0 and alpha-trimmed peak
ran1(1) = 0.0;
ran2(1) = 0.0;
ran3(1) = 0.0;

%Using calibration values from Tromso data 2006, for 6730Å, 7319Å and 7774Å
%calib = [0.5, 0.36, 0.85]
calib = ASK_get_ask_cal(vs.vmjs(vs.vsel),[1,2,3]);

loc = find(calib == 0);
count = length(loc);
if (count > 0)
  disp('WARNING! This routine is about to crash. Go and calibrate your data!')
end

% If we have a background set shift the lower intensity from zero
% to these background intensities.
if ~isempty(dOPS.bkg)
  ran1(1) = dOPS.bkg(1)/(calib(1)/vs.vres(vs.vsel));
  ran2(1) = dOPS.bkg(2)/(calib(2)/vs.vres(vs.vsel));
  ran3(1) = dOPS.bkg(3)/(calib(3)/vs.vres(vs.vsel));
end

% Make the RGB-composite keogram, by mapping everything into [0-1]
RGBoverlay(:,:,3) = max(0,min(1,(keos{1} - ran1(1))/(ran1(2)-ran1(1))));
RGBoverlay(:,:,2) = max(0,min(1,(keos{2} - ran2(1))/(ran2(2)-ran2(1))));
RGBoverlay(:,:,1) = max(0,min(1,(keos{3} - ran3(1))/(ran3(2)-ran3(1))));

%TBR mjs0 = ASK_time_v(fir, 1);
%TBR timeW = [1:nelem]*ste*vs.vres(vs.vsel);

timeV = time_w(:,4) + time_w(:,5)/60 + time_w(:,6)/3600;
%TBR T_length = max(timeV);
yaxis = [1:256];

if ~dOPS.quiet
  close(wbh)
end

if ~isempty(dOPS.subplot4imgs)
  % Create the image row:
  NNN = dOPS.subplot4imgs(2);
  ASK_v_select(1,'quiet');             % Set current camera to 1
  filtStr{1} = vs.vftr{vs.vsel};
  ASK_v_select( 2, 'quiet');           % Cycl.
  filtStr{2} = vs.vftr{vs.vsel};
  ASK_v_select( 3, 'quiet');
  filtStr{3} = vs.vftr{vs.vsel};
  % Was for jj = 1:NNN,
  for jj = NNN:-1:1,
    %jj
    num = fir + (jj-0.5)*(nelem/NNN)*ste;
    % Read the three current images
    ASK_v_select(1,'quiet');             % Set current camera to 1
    im1 = ASK_read_v(num + shft(1),[],[],[],dOPS);     % Read the ASK#1 image
    ASK_v_select( 2, 'quiet');           % Cycl.
    im2 = ASK_read_v(num + shft(2),[],[],[],dOPS);     % Cycl.
    ASK_v_select( 3, 'quiet');           % Cycl..
    im3 = ASK_read_v(num + shft(3),[],[],[],dOPS);     % Cycl..
    % If we want one image instead of the 4-quarter mosaic
    % then here is where we select those frames (or combine them
    % into an RGB)
    if dOPS.oneImg
      % If needed bin the images to the right size
      while size(im3,1) ~= imsiz*2
        im3 = im3(1:2:end,:)/2 + im3(2:2:end,:)/2;
        im3 = im3(:,1:2:end)/2 + im3(:,2:2:end)/2;
        im2 = im2(1:2:end,:)/2 + im2(2:2:end,:)/2;
        im2 = im2(:,1:2:end)/2 + im2(:,2:2:end)/2;
        im1 = im1(1:2:end,:)/2 + im1(2:2:end,:)/2;
        im1 = im1(:,1:2:end)/2 + im1(:,2:2:end)/2;
      end
      switch dOPS.oneImg
       case 1
        RGB_img = max(0,min(1,(im1 - ran3(1))/(ran1(2)-ran1(1))));
       case 2
        RGB_img = max(0,min(1,(im2 - ran2(1))/(ran2(2)-ran2(1))));
       case 3
        RGB_img = max(0,min(1,(im3 - ran1(1))/(ran3(2)-ran3(1))));
       otherwise % 4 or zero or anything really
        RGB_img(:,:,3) = max(0,min(1,(im1 - ran3(1))/(ran1(2)-ran1(1))));
        RGB_img(:,:,2) = max(0,min(1,(im2 - ran2(1))/(ran2(2)-ran2(1))));
        RGB_img(:,:,1) = max(0,min(1,(im3 - ran1(1))/(ran3(2)-ran3(1))));
      end
    else
      % Otherwise we make the 4-quarter mosaic
      while size(im3,1) ~= imsiz
        im3 = im3(1:2:end,:)/2 + im3(2:2:end,:)/2;
        im3 = im3(:,1:2:end)/2 + im3(:,2:2:end)/2;
        im2 = im2(1:2:end,:)/2 + im2(2:2:end,:)/2;
        im2 = im2(:,1:2:end)/2 + im2(:,2:2:end)/2;
        im1 = im1(1:2:end,:)/2 + im1(2:2:end,:)/2;
        im1 = im1(:,1:2:end)/2 + im1(:,2:2:end)/2;
      end
      RGB_img = zeros(imsiz*2,imsiz*2,3);
      
      % for i = 1:3,
      RGB_img( 1:imsiz,          (imsiz+1):imsiz*2,1) = ASK_bytscl(imresize(im3,[1,1].*imsiz),ran1(1), ran1(2));
      RGB_img( 1:imsiz,          1:imsiz,          2) = ASK_bytscl(imresize(im2,[1,1].*imsiz),ran2(1), ran2(2));
      RGB_img((imsiz+1):imsiz*2, 1:imsiz,          3) = ASK_bytscl(imresize(im1,[1,1].*imsiz),ran3(1), ran3(2));
      % end
      
      RGB_img((imsiz+1):imsiz*2,(imsiz+1):imsiz*2,3) = ASK_bytscl(imresize(im1,[imsiz,imsiz]), ran1(1), ran1(2));
      RGB_img((imsiz+1):imsiz*2,(imsiz+1):imsiz*2,2) = ASK_bytscl(imresize(im2,[imsiz,imsiz]), ran2(1), ran2(2));
      RGB_img((imsiz+1):imsiz*2,(imsiz+1):imsiz*2,1) = ASK_bytscl(imresize(im3,[imsiz,imsiz]), ran3(1), ran3(2));
      
    end
    % Display the images in their row:
    subplot(dOPS.subplot4imgs(1),dOPS.subplot4imgs(2),dOPS.subplot4imgs(3)+jj-1)
    PHs{7+jj} = imagesc(RGB_img);axis xy,set(gca,'xtick',[],'ytick',[])
    Time_v = ASK_indx2datevec(num);
    xlabel(sprintf('%02d:%02d:%05.2f',Time_v(4:6)),'fontsize',dOPS.imrowFontsize)
    if nargout > 1
      imstack{1}(:,:,jj) = im1*calib(1)/vs.vres(vs.vsel);
      imstack{2}(:,:,jj) = im2*calib(2)/vs.vres(vs.vsel);
      imstack{3}(:,:,jj) = im3*calib(3)/vs.vres(vs.vsel);
    end
  
  end
  
end

if ~isempty(dOPS.subplot4RGBkeo)
  % This usedto be: subplot(5,1,1)
  % But now one has the option of sorting the subplots in almost
  % whichever way one so desires...
  subplot(dOPS.subplot4RGBkeo(1),dOPS.subplot4RGBkeo(2),dOPS.subplot4RGBkeo(3))
  PHs{1} = imagesc(timeV,yaxis,RGBoverlay);
  axis xy
  try timetick, end
  set(gca,'tickdir','out','xticklabel','')
end
title(vs.vdir{vs.vsel}(1:8),'fontsize',15)

colormap(gray)

if ~isempty(dOPS.subplot4ASK1keo)

  %  This used to be: subplot(5,1,3)
  subplot(dOPS.subplot4ASK1keo(1),dOPS.subplot4ASK1keo(2),dOPS.subplot4ASK1keo(3))
  PHs{3} = imagesc(timeV,yaxis,keos{1}*calib(1)/vs.vres(vs.vsel));axis xy
  cblh(3) = colorbar_labeled(['I(',filtStr{1},') (R)'],'linear','fontsize',12);
  set(cblh(3),'position',get(cblh(3),'position')+[-0.01 0 0 0])
  try timetick, end
  set(gca,'tickdir','out','xticklabel','','box','off')
  
end
if ~isempty(dOPS.subplot4ASK2keo)
  
  % This used to be: subplot(5,1,4)
  subplot(dOPS.subplot4ASK2keo(1),dOPS.subplot4ASK2keo(2),dOPS.subplot4ASK2keo(3))
  PHs{4} = imagesc(timeV,yaxis,keos{2}*calib(2)/vs.vres(vs.vsel));axis xy
  cblh(4) = colorbar_labeled(['I(',filtStr{2},') (R)'],'linear','fontsize',12);
  set(cblh(4),'position',get(cblh(4),'position')+[-0.01 0 0 0])
  try timetick, end
  set(gca,'tickdir','out','xticklabel','')
  
end

if ~isempty(dOPS.subplot4ASK3keo)
  
  % This used to be: subplot(5,1,5)
  subplot(dOPS.subplot4ASK3keo(1),dOPS.subplot4ASK3keo(2),dOPS.subplot4ASK3keo(3))
  PHs{5} = imagesc(timeV,yaxis,keos{3}*calib(3)/vs.vres(vs.vsel));axis xy
  cblh(5) = colorbar_labeled(['I(',filtStr{3},') (R)'],'linear','fontsize',12);
  set(cblh(5),'position',get(cblh(5),'position')+[-0.01 0 0 0])
  try
    timetick, 
  catch
    t0MJS = ASK_time2MJS(ASK_indx2datevec(fir));
    dT = ASK_time2MJS(ASK_indx2datevec(las)) - ASK_time2MJS(ASK_indx2datevec(fir));
    ASK_time_axis(t0MJS,dT);
  end
  set(gca,'tickdir','out')

end
t0MJS = ASK_time2MJS(ASK_indx2datevec(fir));
dT = ASK_time2MJS(ASK_indx2datevec(las)) - ASK_time2MJS(ASK_indx2datevec(fir));
ASK_time_axis(t0MJS,dT);

if nargout
  keos{1} = keos{1}*calib(1)/vs.vres(vs.vsel);
  keos{2} = keos{2}*calib(2)/vs.vres(vs.vsel);
  keos{3} = keos{3}*calib(3)/vs.vres(vs.vsel);
end

figure(CurrFig)
makeASKmenu = 1;
gcfCldr = get(gcf,'Children');
for i1 = 1:length(gcfCldr)
  if strcmp(get(gcfCldr(i1),'type'),'uimenu') & strcmp(get(gcfCldr(i1),'label'),'ASK')
    makeASKmenu = 0;
  end
end
if makeASKmenu
  mh = uimenu(gcf,'Label','ASK');
  eh1 = uimenu(mh,'Label','Zoom in', 'callback','ASK_megablockviewer(1)');
  eh2 = uimenu(mh,'Label','Zoom out','callback','ASK_megablockviewer(2)');
  eh3 = uimenu(mh,'Label','Zoom All-out','callback','ASK_megablockviewer(3)');
  cblStr = sprintf('ASK_keo_autoprint([%d,%d,%d])',dOPS.subplot4ASK3keo);
  eh4 = uimenu(mh,'Label','Print-keos','callback',cblStr);
  clear ASK_megablockviewer
  %eh5 = uimenu(mh,'Label','Forward', 'callback','ASK_megablockviewer(3)');
  %eh6 = uimenu(mh,'Label','Backward','callback','ASK_megablockviewer(4)');
end
