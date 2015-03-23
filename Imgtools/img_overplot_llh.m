function h = img_overplot_llh(ImgIn,long0lat0alt0,longlatalt,optpar,imReg,titleStr,lblstr,gridstyle)
% IMG_OVERPLOT_LLH - longitude-latitude-height points projected
% onto image plane. Image projection of longitude-latitude-altitude
% points calculated with optical parameters OPTPAR for a camera
% with known position (longitude, latitude, altitude).
% 
% This function is written to be a used in a callback to the uimenu
% reading most recent all-sky images to help with pointing of EISCAT
% radars (or ALIS etc).
%
% Calling:
%  h = img_overplot_llh(ImgIn,long0lat0alt0,longlatalt,optpar,titleStr)
% Input:
%  ImgIn         - Image to plot points onto (n1 x n2) or (n1 x n2 x 3)
%  long0lat0alt0 - [longitude latitude altitude] of camera (degrees, km)
%  longlatalt    - [long lat alt] matrix [n1 x n2] of points (degrees, km)
%  optpar        - optical parameters - as obtained with
%                  geometrical calibration with STARCAL
%  titleStr      - title string [1 x nStr]

% Copyright � (20121013) Bj�rn Gustavsson 
% This is free software, licensed under GNU GPL v 3 or later.



% Calculate image coordinate of point projections and
% longitude-latitude grid:
if ~isempty(longlatalt)
  [u,v,uG,vG,cG1,cG2] = project_llh2img(longlatalt,long0lat0alt0,optpar,size(ImgIn(imReg(3):imReg(4),imReg(1):imReg(2),1)),gridstyle);
else
  [u,v,uG,vG,cG1,cG2] = project_llh2img([long0lat0alt0;long0lat0alt0],long0lat0alt0,optpar,size(ImgIn(imReg(3):imReg(4),imReg(1):imReg(2),1)),gridstyle);
  u = [];
  v = [];
end
% Show image
hold off
imagesc(ImgIn)
set(gca,'xtick',[],'ytick',[],'position',[0 0 1 1])
hold on

if nargin > 6 && ~isempty(gridstyle)
  % Possibly plot a grid:
  if strcmp(gridstyle,'ll')
    % then plot longitude latitude grid:
    plot(uG(1:end,1:2:end)+imReg(1),vG(1:end,1:2:end)+imReg(3),'w:')
    plot(uG(1:2:end,1:end)'+imReg(1),vG(1:2:end,1:end)'+imReg(3),'w:')
    % Labels of the grid
    text(10,30,'Lat grid:','fontsize',14,'color','w')
    for i1 = 1:2:length(cG2)
      text(10,35+8*i1,sprintf('%4.1f',cG2(i1)),'fontsize',14,'color','w')
    end
    text(size(ImgIn,2)-70,30,'Long grid:','fontsize',14,'color','w')
    for i1 = 1:2:length(cG1)
      text(size(ImgIn,2)-35,35+8*i1,sprintf('%4.1f',cG1(i1)),'fontsize',14,'color','w')
    end
  else
    % the grid should be an azimuth-zenith grid:
    plot(uG'+imReg(1),vG'+imReg(3),'w:')
    plot(uG(:,1:45:end)+imReg(1),vG(:,1:45:end)+imReg(3),'w:')
    % Labels of the grid
    text(10,30,'Zenith grid:','fontsize',14,'color','w')
    for i1 = 1:length(cG2)
      text(10,35+20*i1,sprintf('%4.1f',cG2(i1)*180/pi),'fontsize',14,'color','w')
    end
    text(size(ImgIn,2)-70,30,'Azimuth grid:','fontsize',14,'color','w')
    for i1 = 1:45:(length(cG1)-1)
      text(size(ImgIn,2)-35,50+i1/45*20,sprintf('%3.0f',cG1(i1)*180/pi),'fontsize',14,'color','w')
    end
  end
end

% Plot the image points:
for i1 = length(u):-1:1,
  h(i1) = plot(u(i1)+imReg(1),v(i1)+imReg(3),'.','markersize',15);
end
% Color the image points:
cmlines(h)
% Label the points:
for i1 = 1:length(h),
% $$$   text(u(i1)+0.03*size(ImgIn,2)+imReg(1),...
% $$$        v(i1)+0.03*size(ImgIn,1)+imReg(3),...
% $$$        num2str(i1),...
% $$$        'color',get(h(i1),'color'),...
% $$$        'FontWeight','bold',...
% $$$        'fontsize',14)
  text(u(i1)+0.03*size(ImgIn,2)+imReg(1),...
       v(i1)+0.03*size(ImgIn,1)+imReg(3),...
       lblstr{i1},...
       'color',get(h(i1),'color'),...
       'FontWeight','bold',...
       'fontsize',14)
end
% If there is a title string then decorate the image a bit:
if nargin > 4
  %updStr = clock;
  set(gcf,'name',titleStr)
  text(5,size(ImgIn,1)-10,...
       sprintf('Updated %4d%02d%02d %02d:%02d:%02d',floor(clock)),...
       'fontsize',14,...
       'FontWeight','bold',...
       'color','w')
end

% Maximize the image frame in the figure:
set(gca,'position',[0 0 1 1])
