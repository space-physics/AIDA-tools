function [varargout] = star_int_model(img_in,optpar,optmode,plstars,starpar,OPTS,BSTRNR)
% STAR_INT_MODEL - Model and plot of star
% 
% Calling:
%  [stars_Ints] = star_int_model(img_in,optpar,optmode,plstars,starpar,OPTS,BSTRNR)
%


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


mode = optmode;

dl = 10;
if ~isempty(OPTS) & isfield(OPTS,'regsize')
  dl = OPTS.regsize;
end

% ua = [];
% va = [];
more off
b = size(img_in);
bx = b(2);
by = b(1);

imax = min(max(size(plstars),max(size(starpar))));
%TBR?: idnr = 0;

% Determine the coordinate system for the camera.
alpha0 = optpar(3);
beta0 = optpar(4);
gamma0 = optpar(5);
if length(optpar) > 9
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,optpar(10));
else
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
end

for i1 = imax:-1:1,
  
  clear sortids1 order x1 indx1
  %Determine the projected position of the star on the image
  az = plstars(i1,1);
  ze = plstars(i1,2);
  
  [x0,y0] = camera_model(az,ze,e1,e2,e3,optpar,mode,size(img_in));
  
  if ( ( 1 < x0 & x0 < bx ) & ( 1 < y0 & y0 < by ) )
    
    % Determine the part of the image confining the star.
    xmin = floor(min(max(x0-dl/2,1),bx-dl));
    xmax = floor(max(min(x0+dl/2,bx),(dl+1)));
    ymin = floor(min(max(y0-dl/2,1),by-dl));
    ymax = floor(max(min(y0+dl/2,by),(dl+1)));
    
    % Find the star in the region of interest.
    
    starmat = img_in(ymin:ymax,xmin:xmax);
    starmat = medfilt2(starmat([1 1:end end],[1 1:end end]),[3 3]);
    starmat = starmat(2:end-1,2:end-1);
    x = xmin:xmax;
    y = ymin:ymax;
    [x1,y1] = meshgrid(x,y);
    if ~isempty(OPTS) & isfield(OPTS,'bgtype') & strcmp(OPTS.bgtype,'complicated')
      
      b = [starmat(1,:),starmat(end,:),starmat(:,1)',starmat(:,end)',starmat(3,:),starmat(end-2,:),starmat(:,3)',starmat(:,end-2)'];
      X = [x1(1,:),x1(end,:),x1(:,1)',x1(:,end)',x1(3,:),x1(end-2,:),x1(:,3)',x1(:,end-2)'];
      Y = [y1(1,:),y1(end,:),y1(:,1)',y1(:,end)',y1(3,:),y1(end-2,:),y1(:,3)',y1(:,end-2)'];
      bakgr2 = griddata(X,Y,b,x1,y1,'v4')*2/3+griddata(X,Y,b,x1,y1,'cubic')/3;
      
    else
      
      b = [starmat(1,:),starmat(end,:),starmat(:,1)',starmat(:,end)'];
      X = [x1(1,:),x1(end,:),x1(:,1)',x1(:,end)'];
      Y = [y1(1,:),y1(end,:),y1(:,1)',y1(:,end)'];
      bakgr2 = griddata(X,Y,b,x1,y1,'cubic');
      
    end
    
    starmat = img_in(ymin:ymax,xmin:xmax);
    
    fynd = starint3(starpar(i1,:),xmin,xmax,ymin,ymax);
    star_intm = (starmat-bakgr2).*(fynd>.07*(max(max(fynd))));
    if nargout
      stars_Ints{i1} = star_intm;
    end
    clf
    subplot(2,2,1)
    imagesc(xmin:xmax,ymin:ymax,starmat)
    hold on
    plot(starpar(i1,1),starpar(i1,2),'w.','markersize',16)
    hold off
    colorbar
    subplot(2,2,2)
    imagesc(bakgr2)
    title(num2str(BSTRNR(i1)))
    colorbar
    subplot(2,2,3)
    imagesc(fynd)
    colorbar
    subplot(2,2,4)
    imagesc(starmat-fynd-bakgr2)
    colorbar
    title(num2str(starpar(i1,:)))
    drawnow
    if isfield(OPTS,'pausetime')
      if (OPTS.pausetime < 0)
        pause
      else
        pause(OPTS.pausetime)
      end
    end
    
  end
  
end
if nargout
  varargout{1} = stars_Ints;
end
