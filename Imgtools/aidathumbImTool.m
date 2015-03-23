function imH = aidathumbImTool(im,ops)
% AIDATHUMBIMTOOL - display image and intensities in centre line and column
%   Works for both RGB-images and grayscale images.
%
% Calling:
%   imH = aidathumbImTool(im,ops)
% Input:
%   im - image, either [nR x nC x 3] rgb-image, or [nR x nC]
%        gray-scale image


%   Copyright © 20140122 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

clf

% A layout where the image display covers 4x4 subplots out of 5x5
% and the line-cuts get 4x1 and 1x4 subplots seems like an OK
% layout:
axImg = subplot(5,5,[1:4,6:9,11:14,16:19]);

% Displaying of image
if strcmpi(ops.ImShowFcn,'imagesc')
  imH = imagesc(im);
else
  imH = imshow(im,'Parent',axImg);
end

set(gca,'xticklabel','','tickdir','out')
imsz = size(im);
axIm = axis;
clbH = [];
hold on

% With central line and column plotted ontop:
phX = plot([1 imsz(2)],imsz(1)*[1,1]/2,'k--','linewidth',0.5);
phY = plot([1 1]*imsz(2)/2,[1 imsz(1)],'k--','linewidth',0.5);


if length(imsz) > 2 % RGB
  
  %% Then we should plot the R, G and B chanels along those central
  %  cuts on the right side of the image:
  axC = subplot(5,5,[5:5:20]); %#ok<*NBRAK>
  pC = plot(axC,squeeze(im(:,round(imsz(2)/2),:)),1:size(im,1),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles);
  ax_C = axis;
  axis([ax_C(1:2),axIm(3:4)])
  set(gca,'ydir',get(axImg,'ydir')) % Give the column plot the same
                                    % direction of the
                                    % pixel/vertical coordinate
  set(gca,'yaxisLocation','right','yticklabel','')
  % and below the bottom of the image:
  axR = subplot(5,5,21:24);
  pR = plot(axR,1:size(im,2),squeeze(im(round(imsz(1)/2),:,:)),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles);
  ax_R = axis;
  axis([axIm(1:2),ax_R(3:4)])
  set(gca,'xdir',get(axImg,'xdir'))
  % Set the correct colors of the lines:
  set(pR(1),'color','r')
  set(pR(2),'color','g')
  set(pR(3),'color','b')
  set(pC(1),'color','r')
  set(pC(2),'color','g')
  set(pC(3),'color','b')
  imR = im(:,:,1);
  imG = im(:,:,2);
  imB = im(:,:,3);
  
  [imHist(:,1)] = hist(double(imR(:)),unique(double(im(:))));
  [imHist(:,2)] = hist(double(imG(:)),unique(double(im(:))));
  [imHist(:,3)] = hist(double(imB(:)),unique(double(im(:))));
  
  xHist = unique(double(im(:)));
  
else
  
  % We have a gray-scale image so same as above, except only for
  % one pair of image intensity curves:
  colormap(bone(256))
  axC = subplot(5,5,[5:5:20]);
  plot(axC,squeeze(im(:,round(imsz(2)/2))),1:size(im,1),...
       'linewidth',ops.LineWidths,...
       'linestyle',ops.LineStyles,...
       'color',    ops.LineColor);
  ax_C = axis;
  axis([ax_C(1:2),axIm(3:4)])
  
  set(gca,'ydir',get(axImg,'ydir'))
  set(gca,'yaxisLocation','right','yticklabel','')
  axR = subplot(5,5,21:24);
  plot(axR,1:size(im,2),squeeze(im(round(imsz(1)/2),:)),...
       'linewidth',ops.LineWidths,...
       'linestyle',ops.LineStyles,...
       'color',    ops.LineColor);
  ax_R = axis;
  axis([axIm(1:2),ax_R(3:4)])
  set(gca,'xdir',get(axImg,'xdir'))
  
  [imHist,xHist] = hist(double(im(:)),unique(double(im(:))));
  if strcmpi(ops.colorbar,'always')
    axes(axImg)
    clbH = colorbar_labeled('');
    set(clbH,'yticklabel','')
  end
  
end

axes(axImg)
% Make the image panel respond to mouse-clicks:
set(imH,'ButtonDownfcn','imthumbImToolupdateRCcuts')

%% If needed create the scale and colormap menubars
makeScaleMenu = 1;
gcfCldr = get(gcf,'Children');
for i1 = 1:length(gcfCldr)
  if strcmp(get(gcfCldr(i1),'type'),'uimenu') && strcmp(get(gcfCldr(i1),'label'),'Scale')
    makeScaleMenu = 0;
  end
end

if makeScaleMenu
  
  mh = uimenu(gcf,'Label','Scale');
  uimenu(mh,'Label','Linear',  'callback','imthumbScaler(7)');
  uimenu(mh,'Label','SQRT',    'callback','imthumbScaler(8)');
  uimenu(mh,'Label','LOG',     'callback','imthumbScaler(9)');
  uimenu(mh,'Label','Hist-eq', 'callback','imthumbScaler(10)');
  uimenu(mh,'Label','Brighten','callback','imthumbScaler(11)','separator','on');
  uimenu(mh,'Label','Darken',  'callback','imthumbScaler(12)');
  uimenu(mh,'Label','min-MAX', 'callback','imthumbScaler(1)','separator','on');
  uimenu(mh,'Label','99.9%',   'callback','imthumbScaler(2)');
  uimenu(mh,'Label','99%',     'callback','imthumbScaler(3)');
  uimenu(mh,'Label','97%',     'callback','imthumbScaler(4)');
  uimenu(mh,'Label','95%',     'callback','imthumbScaler(5)');
  uimenu(mh,'Label','90%',     'callback','imthumbScaler(6)');
  
  colormapmenu = 0;
  if strcmpi(ops.lutbar,'on')
    try
      lutbar
      colormapmenu = 0;
    catch
      colormapmenu = 1;
    end
  end
  if colormapmenu
    mh2  = uimenu(gcf,'Label','Colour');
    uimenu(mh2,'Label','bone',  'callback','colormap(bone)');
    uimenu(mh2,'Label','gray',  'callback','colormap(gray)');
    uimenu(mh2,'Label','jet',   'callback','colormap(jet)');
    uimenu(mh2,'Label','hot',   'callback','colormap(hot)');
    uimenu(mh2,'Label','pink',  'callback','colormap(pink)');
    uimenu(mh2,'Label','copper','callback','colormap(copper)');
    uimenu(mh2,'Label','winter','callback','colormap(winter)');
    uimenu(mh2,'Label','autumn','callback','colormap(autumn)');
    uimenu(mh2,'Label','summer','callback','colormap(summer)');
    uimenu(mh2,'Label','spring','callback','colormap(spring)');
    uimenu(mh2,'Label','cool',  'callback','colormap(cool)');
    uimenu(mh2,'Label','hsv',   'callback','colormap(hsv)');
  end
  
end

% Stuff away necessay handles (image, lines and axes handles) and
% sizes for use by the buttondownfunctioncallback: 
Udata.axImg  = axImg;
Udata.phX    = phX;
Udata.phY    = phY;
Udata.clbH   = clbH;
Udata.axC    = axC;
Udata.axR    = axR;
Udata.imsz   = imsz;
Udata.imHist = imHist;
Udata.xHist  = xHist;
Udata.cmap   = colormap;
Udata.ops    = ops;
set(gcf,'userdata',Udata)
