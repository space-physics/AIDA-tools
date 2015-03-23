function ph = imthumbImToolupdateRCcuts
% IMTHUMBIMTOOlUPDATERCCUTS - update line and column intensities cuts
%   Works for both RGB-images and grayscale images.
%   Callback-function for Imthumb.m
% 
% Calling:
%   ph = imthumbImToolupdateRCcuts
% Input:
%   im - image, either [nR x nC x 3] rgb-image, or [nR x nC]
%        gray-scale image
%   

%   Copyright © 20140122 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% Full crosshair seems like a good choice of marker for the pointer
set(gcf,'pointer','fullcrosshair')

pause(0.2)
warningSpwewer = 'MATLAB:hg:patch:RGBColorDataNotSupported';
warningSpwewerState = warning('QUERY',warningSpwewer);
warning('OFF','MATLAB:hg:patch:RGBColorDataNotSupported');

% Retrieve the handles to images and subplots and such.
Udata = get(gcf,'userdata');
axImg  = Udata.axImg;  % handle to image
phX    = Udata.phX;    % handle to the horizontally overplotted line  
phY    = Udata.phY;    % handle to the vertically overplotted line  
clbH   = Udata.clbH;   % possibly handle to colorbar
axC    = Udata.axC;    % handle to the panel for row-line-plots     
axR    = Udata.axR;    % handle to the panel for column-line-plots  
imsz   = Udata.imsz;   % Size of the original image                 
imHist = Udata.imHist; % Image intensity histogram
xHist  = Udata.xHist;  % Intensities in histogram
ops    = Udata.ops;  % options struct
axZoom = Udata.axZoom;
zoomaxsize = ops.ImTzoomaxsize;
zoom2nrpix = ops.ImTzoom2nrpix;
% Remove the old overplotted lines (since we've selected a new
% pair to plot):
axes(axImg)
if ishandle(axZoom)
  delete(axZoom)
end
cxImg = caxis;
if ishandle(phX)
  delete(phX)
  delete(phY)
end
if ishandle(clbH)
  delete(clbH)
end
% Retrieve the image data:
CDATA = get(findall(gca,'type','image'),'cdata');
axIm = axis;

% Get the coordinates of the pointer:
point1 = get(gca,'CurrentPoint'); % button down detection
seltype = get(gcf,'SelectionType');

% over-plot the new horizontal and vertical lines on the image:
switch seltype
 case 'alt' % Zoom then plot a small + centred on the selected point
  phX = plot(point1(1,2)+zoom2nrpix*[-1 1]/2,point1(1,2)*[1,1],'k--','linewidth',0.5);
  phY = plot([1 1]*point1(1,1),point1(1,2)+zoom2nrpix*[-1 1]/2,'k--','linewidth',0.5);
 case 'extend' % Histogram - plot just a simple point to keep phXY handles
  phX = plot([1,1],[1,1],'k--','linewidth',0.5);
  phY = plot([1,1],[1 1],'k--','linewidth',0.5);
 otherwise % Normal/open plot the selected line and column
  phX = plot([1 imsz(2)],point1(1,2)*[1,1],'k--','linewidth',0.5);
  phY = plot([1 1]*point1(1,1),[1 imsz(1)],'k--','linewidth',0.5);
end
% Determine the closest row and column in the image:
iR = max(1,min(round(point1(1,2)),size(CDATA,1)));
iC = max(1,min(round(point1(1,1)),size(CDATA,2)));

if length(imsz) > 2 % RGB
  
  switch seltype
   case 'alt'
% $$$     if ishandle(axZoom)
% $$$       delete(axZoom)
% $$$     else
      %% Then we plot the R, G and B chanels along the selected
      %  column on the right side of the image:
      axes(axC)
      pC = plot(axC,squeeze(CDATA(:,iC,:)),1:size(CDATA,1),...
                'linewidth',ops.LineWidths,...
                'linestyle',ops.LineStyles);
      ax_C = axis;
      axis([ax_C(1:2),axIm(3:4)])
      set(gca,'ydir',get(axImg,'ydir')) % Give the column plot the same
                                        % direction of the
                                        % pixel/vertical coordinate
      set(gca,'yaxisLocation','right','yticklabel','')
      
      % and below the bottom of the image:
      axes(axR)
      pR = plot(1:size(CDATA,2),squeeze(CDATA(iR,:,:)),...
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
      axes(axImg)
      imgcaC = get(findall(get(gca,'children'),'type','image'),'CData');
      axPos = get(gca,'position');
      % axZoom = axes('position',[axPos(1)+((point1(1,1)+20)/size(imgcaC,2))*axPos(3), axPos(2)+(size(imgcaC,1)-(point1(1,2)+15))/size(imgcaC,1)*axPos(4),0.15,0.15]);
      axZoom = axes('position',[axPos(1)+((point1(1,1)+20)/size(imgcaC,2))*axPos(3),...          % x-coordinate of lower left corner of the zoom-axis 
                          axPos(2)+(size(imgcaC,1)-(point1(1,2)+15))/size(imgcaC,1)*axPos(4),... % y-coordinate of lower left corner of the zoom-axis 
                          zoomaxsize*[1,1]]);                                                    % width and height of the zoom axis
      imZH = imagesc(imgcaC,'parent',axZoom);
      %axis([point1(1,1) + [-10 10],point1(1,2) + [-10 10]])
      %axis([point1(1,1) + [-10 10],point1(1,2) + [-10 10]])
      axis equal
      axis([point1(1,1)+zoom2nrpix*[-1 1]/2, point1(1,2) + zoom2nrpix*[-1 1]/2])
      set(imZH,'ButtonDownfcn','imthumbchangezoom')
% $$$     end
   case 'extend'
    %% Plot the image histograms and cumulative histograms
    axes(axR)
    sHx = stairs(xHist,imHist,'r');
    set(sHx,'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles)
    set(sHx(1),'color','r')
    set(sHx(2),'color','g')
    set(sHx(3),'color','b')
    xlabel('Intensity histogram ("intensity")','fontsize',ops.fontsizes)
    ylabel('# of pixels','fontsize',ops.fontsizes)
    axes(axC)
    sHy = stairs(cumsum(imHist)/prod(imsz(1:2)),repmat(xHist,1,3));
    set(sHy,'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles)
    set(sHy(1),'color','r')
    set(sHy(2),'color','g')
    set(sHy(3),'color','b')
    axis tight
    set(gca,'yaxisLocation','right')
    ylabel('Cumulative intensity histogram ("intensity")','fontsize',ops.fontsizes)
    xlabel('% of pixels','fontsize',ops.fontsizes)
    
   case 'open'
    %% Plot the Hue Saturation and Value of the RGB-cuts
    % Row
    axes(axR)
    axp = get(gca,'position');
    hsvR = rgb2hsv(squeeze(CDATA(iR,:,:)));
    clrR = hsv2rgb(hsvR);
    hold off
    phR3 = plot(1:size(CDATA,2),hsvR(:,3),'m.');
    hold on 
    phR2 = plot(1:size(CDATA,2),hsvR(:,2),'c.');
    phRSC = scatter(1:length(clrR),hsvR(:,1),15,squeeze(clrR),'filled');
    ax_R = axis;
    hold off
    axis([axIm(1:2),ax_R(3:4)])
    legend([phRSC(1),phR2,phR3],'Hue','Saturation','Value','location','southeastoutside')
    set(gca,'position',axp)
    set(gca,'xdir',get(axImg,'xdir'))
    % Column
    axes(axC)
    hsvC = rgb2hsv(squeeze(CDATA(:,iC,:)));
    clrC = hsv2rgb(hsvC);
    hold off
    phC3 = plot(hsvC(:,3),1:size(CDATA,1),'m.');
    hold on 
    phC2 = plot(hsvC(:,2),1:size(CDATA,1),'c.');
    phCSC = scatter(hsvC(:,1),1:length(clrC),15,squeeze(clrC),'filled');
    ax_C = axis;
    axis([ax_C(1:2),axIm(3:4)])
    hold off
    set(gca,'ydir',get(axImg,'ydir')) % Give the column plot the same
                                      % direction of the
                                      % pixel/vertical coordinate
    
    set(gca,'yaxisLocation','right','yticklabel','')
    pR = [phRSC(:);phR2(:);phR3(:)];
    pC = [phCSC(:);phC2(:);phC3(:)];
    
   otherwise
    %% Then we plot the R, G and B chanels along the selected
    %  column on the right side of the image:
    axes(axC)
    pC = plot(axC,squeeze(CDATA(:,iC,:)),1:size(CDATA,1),...
              'linewidth',ops.LineWidths,...
              'linestyle',ops.LineStyles);
    ax_C = axis;
    axis([ax_C(1:2),axIm(3:4)])
    set(gca,'ydir',get(axImg,'ydir')) % Give the column plot the same
                                      % direction of the
                                      % pixel/vertical coordinate
    set(gca,'yaxisLocation','right','yticklabel','')
    
    % and below the bottom of the image:
    axes(axR)
    pR = plot(1:size(CDATA,2),squeeze(CDATA(iR,:,:)),...
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
    
  end
  
else % Grayscale
  %  for gray-scale image do same as above, except only for the
  %  image intensity curves: 
  switch seltype
   case 'alt'
    if ishandle(axZoom)
      delete(axZoom)
      % disp('b')
    else
    axes(axC)
    pC = plot(axC,CDATA(:,iC),1:size(CDATA,1),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles,...
            'color',    ops.LineColor);
    ax_C = axis;
    axis([ax_C(1:2),axIm(3:4)])
    set(gca,'ydir',get(axImg,'ydir'))
    set(gca,'yaxisLocation','right')
    
    axes(axR)
    pR = plot(axR,1:size(CDATA,2),CDATA(iR,:),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles,...
            'color',    ops.LineColor);
    ax_R = axis;
    axis([axIm(1:2),ax_R(3:4)])
    set(gca,'xdir',get(axImg,'xdir'))
    % disp('F')
    
    % set(pR(1),'color','r')
    % set(pC(1),'color','r')
    if strcmpi(ops.colorbar,'always')
      axes(axImg)
      clbH = colorbar_labeled('');
    end
      % disp('c')
      axes(axImg)
      imgcaC = get(findall(get(gca,'children'),'type','image'),'CData');
      axPos = get(gca,'position');
      % axZoom = axes('position',[axPos(1)+(point1(1,1)/size(imgcaC,2))*axPos(3)  axPos(2)+(size(imgcaC,1)-point1(1,2))/size(imgcaC,1)*axPos(4),0.15,0.15]);
      axZoom = axes('position',[axPos(1)+((point1(1,1)+20)/size(imgcaC,2))*axPos(3),...          % x-coordinate of lower left corner of the zoom-axis 
                          axPos(2)+(size(imgcaC,1)-(point1(1,2)+15))/size(imgcaC,1)*axPos(4),... % y-coordinate of lower left corner of the zoom-axis 
                          zoomaxsize*[1,1]]);                                                    % width and height of the zoom axis
      imZH = imagesc(imgcaC,'parent',axZoom);% axis([point1(1,1)+[-10 10],point1(1,2)+[-10 10]])
      axis equal
      axis([point1(1,1)+zoom2nrpix*[-1 1]/2, point1(1,2) + zoom2nrpix*[-1 1]/2])
      set(imZH,'ButtonDownfcn','imthumbchangezoom')
      % keyboard
    end
   case 'extend'
    % disp('D')
    %% Plot the image histograms and cumulative histograms
    axes(axR)
    sHx = stairs(xHist,imHist,'r');
    set(sHx,'color',ops.LineColor,'linewidth',ops.LineWidths,'linestyle',ops.LineStyles)
    xlabel('Intensity histogram ("intensity")','fontsize',ops.fontsizes)
    ylabel('# of pixels','fontsize',ops.fontsizes)
    axRlims = axis;
    hold on
    plot(cxImg(1)*[1,1],axRlims(3:4),'k--')
    plot(cxImg(2)*[1,1],axRlims(3:4),'k--')
    hold off
    
    axes(axC)
    sHy = stairs(cumsum(imHist)/prod(imsz),xHist,'r');
    set(sHy,'color',ops.LineColor,'linewidth',ops.LineWidths,'linestyle',ops.LineStyles)
    axis tight
    axClims = axis;
    hold on
    plot(axClims(1:2),cxImg(1)*[1,1],'k--')
    plot(axClims(1:2),cxImg(2)*[1,1],'k--')
    hold off
    
    set(gca,'yaxisLocation','right')
    ylabel('Cumulative intensity histogram ("intensity")','fontsize',ops.fontsizes)
    xlabel('% of pixels','fontsize',ops.fontsizes)
    if strcmpi(ops.colorbar,'hist') || strcmpi(ops.colorbar,'always')
      axes(axImg)
      clbH = colorbar_labeled('');
      set(clbH,'yticklabel','')
    end
    
   otherwise
    axes(axC)
    pC = plot(axC,CDATA(:,iC),1:size(CDATA,1),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles,...
            'color',    ops.LineColor);
    ax_C = axis;
    axis([ax_C(1:2),axIm(3:4)])
    set(gca,'ydir',get(axImg,'ydir'))
    set(gca,'yaxisLocation','right')
    
    axes(axR)
    pR = plot(axR,1:size(CDATA,2),CDATA(iR,:),...
            'linewidth',ops.LineWidths,...
            'linestyle',ops.LineStyles,...
            'color',    ops.LineColor);
    ax_R = axis;
    axis([axIm(1:2),ax_R(3:4)])
    set(gca,'xdir',get(axImg,'xdir'))
    
    % set(pR(1),'color','r')
    % set(pC(1),'color','r')
    if strcmpi(ops.colorbar,'always')
      axes(axImg)
      clbH = colorbar_labeled('');
      set(clbH,'yticklabel','')
    end
    
  end % Switch seltype
  
end


% Stuff away necessay handles and sizes for use by the
% buttondownfunctioncallback: 
Udata.axImg  = axImg;
Udata.phX    = phX;
Udata.phY    = phY;
Udata.clbH   = clbH;
Udata.axC    = axC;
Udata.axR    = axR;
Udata.imsz   = imsz;
Udata.imHist = imHist;
Udata.xHist  = xHist;
Udata.axZoom = axZoom;

set(gcf,'userdata',Udata)
if nargout
  ph = [pR(:);pC(:)];
end

if strcmpi(warningSpwewerState.state,'off')
  warning('ON','MATLAB:hg:patch:RGBColorDataNotSupported');
end
