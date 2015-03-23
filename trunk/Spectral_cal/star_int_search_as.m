function [idstarsok,stars_par] = star_int_search_as(img_in,optpar,optmode,plstars,OPTS)
% STAR_INT_SEARCH identifies points in image with stars, make a parametrisation
%
% Calling:
%  [idstarsok,stars_par] = star_int_search(img_in,optpar,optmode,plstars,OPTS)
% Input:
%  img_in  - Image in which to search for star.
%  optpar  - Optical parameters the describe the camera characteristics.
%  optmode - Optical transfer function.
%  plstars - Bright Star CAtalog stars that are above the horison
%  OPTS    - SPC_TYPICAL_OPS struct see that function
% Output:
%  idstarsok - Array wuth parameters of identified stars found in IMG_IN:
%            idstarsok(n,1) - Running index
%            idstarsok(n,2) - Horizontal image position (pixels) of 2D Gaussian
%            idstarsok(n,3) - Vertical image position (pixels) of 2D Gaussian
%            idstarsok(n,4) - Max of 2D Gaussian
%            idstarsok(n,5) - Max image intensity of star
%            idstarsok(n,6) - Total image intensity of star
%            idstarsok(n,7) - Total image intensity of 2D Gaussian
%            idstarsok(n,8) - Running index
%            idstarsok(n,9) - Star index (BSC-NR)
%            idstarsok(n,10) - Total error
%            idstarsok(n,11) - Magnitude 
%  STARS_PAR - Parameters of the 2D Gaussian, see STARDIFF for details


%   Copyright © 1997 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% global bx by

mode = optmode;

dl = 10;
if ~isempty(OPTS) & isfield(OPTS,'regsize')
  dl = OPTS.regsize;
end

ua = [];
va = [];
more off
bxy = size(img_in);
bx = bxy(2);
by = bxy(1);

imax = max(size(plstars));
idnr = 0;

% Determine the coordinate system for the camera.
alpha0 = optpar(3);
beta0 = optpar(4);
gamma0 = optpar(5);

[Vmag,Ivmag] = sort(plstars(:,4));
if length(optpar) > 9
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0,optpar(10));
else
  [e1,e2,e3] = camera_base(alpha0,beta0,gamma0);
end

% AS: 2007-06-26: Optimisation routine options
if isfield(OPTS,'use_optim_opts') && OPTS.use_optim_opts
  optopt=optimset('tolx',0.1,'tolfun',1);
else
  optopt=optimset('fminsearch');
end

%for i = 1:imax,
for j = 1:length(Ivmag),
  i = Ivmag(j);
  
  clear sortids1 order x1 indx1
  %Determine the projected position of the star on the image
  az = plstars(i,1);
  ze = plstars(i,2);
  
  [x0,y0] = camera_model(az,ze,e1,e2,e3,optpar,mode,bxy);
  
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
      
      b = [starmat(1,:),starmat(end,:),...
           starmat(:,1)',starmat(:,end),...
           starmat(3,:),starmat(end-2,:),...
           starmat(:,3)',starmat(:,end-2)'];
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
    
    [max_I,indxmax] = max(starmat(:)-bakgr2(:));
    td_max = img_in(y1(indxmax),x1(indxmax))-bakgr2(y1(indxmax)-min(y1(:))+1,x1(indxmax)-min(x1(:))+1);
    
    startvec = [x1(indxmax),y1(indxmax),td_max,1^2,0,1^2];
    
    % AS: 2007-06-25
    if isfield(OPTS,'use_stardiff_as') & OPTS.use_stardiff_as

      % background subtraction
      starmat2=starmat-bakgr2;
      bg3 = mean([starmat2(1,:) starmat2(end,:) starmat2(:,end).'  ...
                  starmat2(:,1).']);
      starmat2=starmat2-bg3;
      
      % scale intensities
      i_scl=max(starmat2(:));
      startvec(3)=startvec(3)/i_scl;
      
      % educated guess at uncertainty in intensity
      i_err=median(abs(starmat2(:)));
      i_err=i_err/i_scl;

      optopt=optimset('tolx',0.01,'tolfun',0.01);


      
      [starpar,fval,xflg,qout] = fminsearch(@(fv) stardiff_as(fv,x1,y1, ...
                                           starmat2/i_scl, ...
                                             x1(indxmax), y1(indxmax), ...
                                             2,i_err), startvec,optopt);

      % un-scale intensity again
      starpar(3)=starpar(3)*i_scl;
      
      fprintf('%d/%d: i_scl=%.1f, i_err=%.1f, fiterr=%.2f, fcount=%d\n', ...
              j,length(Ivmag),i_scl,i_err*i_scl,fval,qout.funcCount);
      starpar
      
    else
      % AS 2007-06-26: modified to use options structure
      starpar = fminsearch(@(fv) stardiff3(fv,xmin,xmax,ymin,ymax,starmat-bakgr2,x1(indxmax),y1(indxmax)),startvec,optopt);%[0,5e-2,0,0,0,0,0,0,0,0,0,0,0,3000],[],xmin,xmax,ymin,ymax,starmat-bakgr2,x1(indxmax),y1(indxmax));

    end
    
    fynd = starint3(starpar,xmin,xmax,ymin,ymax);
    
    if isfield(OPTS,'plotintermediates')
      
      subplot(2,2,1),imagesc(xmin:xmax,ymin:ymax,starmat),axis xy,colorbar
      subplot(2,2,2),imagesc(xmin:xmax,ymin:ymax,starmat-bakgr2),axis xy,colorbar
      subplot(2,2,3),imagesc(xmin:xmax,ymin:ymax,fynd),axis xy,colorbar
      hold on
      plot(x1(indxmax),y1(indxmax),'wp')
      plot(x0,y0,'kh')
      plot(starpar(1),starpar(2),'w.','markersize',15)
      hold off
      subplot(2,2,4),imagesc(xmin:xmax,ymin:ymax,starmat-bakgr2-fynd),axis xy,colorbar
      
      pause
      
    end
    
    star_intm = (starmat-bakgr2).*(fynd>.07*(max(max(fynd))));
    
    if ( xmin < starpar(1) & starpar(1) < xmax & ymin < starpar(2) & starpar(2) < ymax )
      
      star_intt = sum(sum(star_intm));
      star_max = max(max(star_intm));
      idnr = idnr + 1;
      identstars(idnr,1) = i;
      identstars(idnr,2) = starpar(1); 	%starpos in image(x)
      identstars(idnr,3) = starpar(2); 	%starpos in image(y)
      identstars(idnr,4) = starpar(3);  % max of 2D-Gauss
      identstars(idnr,5) = star_max; 	%max count from star
      identstars(idnr,6) = star_intt; 	%total counts from star
      identstars(idnr,7) = sum(fynd(:));%total counts from star-fit
      identstars(idnr,8) = i;
      identstars(idnr,9) = plstars(i,3); %star index
      identstars(idnr,10) = sum((fynd(:)-starmat(:)-bakgr2(:)).^2); %total error
      identstars(idnr,11) = Vmag(i);
      
      stars_par(idnr,:) = starpar;
      % And remove the image intensity from this star to avoid
      % getting close stars picking up its intensity
      img_in(ymin:ymax,xmin:xmax) = img_in(ymin:ymax,xmin:xmax) - fynd;
      clear starpar starmat fynd ;
      
    end
    
  end
  
end

idstarsok = identstars;
