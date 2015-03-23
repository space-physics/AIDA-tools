function tomo_ops = make_tomo_ops(stns)
% MAKE_TOMO_OPS - User interface to set some parameters for the
% tomographic inversion. 
% These options are: 
% 1, 'quiet border' the frame around the images where the ratio
%     between observed image and current projection is set to 1
%     this is to avoid problems with edge effects an porly known
%     flat-field sensitivity corrections; 
% 2, relative scaling of images and the normalization region to
%    avoid problems with absolute sensitivity uncertainties and
%    such; 
% 3, choice of itterative method; 
% 4, choise of 3-D filtering method and filter kernel.
% 5, display images and intermediate projections of
%    reconstruction. [ {'no-disp'} | 'disp' ]
% Input parameter: 
% STNS - a station-struct array
% 
% Calling:
% tomo_ops = make_tomo_ops(stns)
%
% See also: TOMO_INP_IMAGES, TOMO_SKELETON

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if  ( nargin == 1 )
  
  disp('Currently these iterative methods are implemented')
  disp('1. Multiplicative ART')
  disp('2. Multiplicative SIRT')
  disp('3. SIRT')
  disp('4. FMAPE')
  disp('--------')
  t_t = in_def2('Which kind of iteration method should we use? ',1);
  for i1 = numel(stns):-1:1,
    tomo_ops(i1).tomotype = t_t;
  end
  if ~any([1 2 3 4]==tomo_ops(1).tomotype)
    
    error('Asking for unimplemented iteration method')
    
  end
  
  sp = fix_subplots_tomo(length(stns(:)));
  
  for i1 = 1:length(stns(:)),
    
    subplot(sp(1),sp(2),i1)
    imagesc(stns(i1).img),axis xy
    imgs_smart_caxis(0.001,stns(i1).img)
    title(['Image: ',num2str(i1),' Station ',num2str(stns(i1).obs.station)])
    
  end
  
  [tomo_ops(:).randorder] = deal(nan*ones(size(tomo_ops)));
  if tomo_ops(1).tomotype == 1
    % 3 randomclassiffication of stations
    
    
    disp('For ART it might be of importance in which order the stations')
    disp('are used. Therefore there are 3 possible groups, first (1),')
    disp('middle(2) or last (3)')
    randorder = in_def2('Group the stations into classes? (vector notation, ex: [2 2 1 3])',2);
    
    for i2 = 1:length(stns),
      tomo_ops(i2).randorder = max(min(randorder(i2),3),1);
    end
  end
  
  % 1 select quiet border 
  disp('Typically it is good to set the update-ratio to 1 on the ')
  disp('borders of images. Unless there is special reasons not to')
  disp('this is adviseable.')
  no_qbi = in_def2(['Are there any images that should not have quiet' ...
		    ' borders?'],0);
  for i1 = 1:length(stns)
    
    if ~any(no_qbi==i1)
      
      clf
      imagesc(stns(i1).img),axis xy
      imgs_smart_caxis(0.001,stns(i1).img)
      hold on
      try
        contour('v6',stns(i1).proj,8,'k')
      catch
      end
      title(['Select the ''quiet frame'' for IMAGE: ', ...
	     num2str(i1)])
      
      % Disable any widowbutton down functions
      set(gcf,'windowbuttondownfcn',' ') ;
      % Get frame
      waitforbuttonpress            ;
      pnt = get(gcf,'currentpoint') ;
      xy1 = get(gca,'currentpoint') ;
      rbbox([pnt 0 0],pnt)          ;
      xy2 = get(gca,'currentpoint') ;
      
      xx  = [xy1(1,1) xy2(1,1)] ;
      yy  = [xy1(1,2) xy2(1,2)] ;
      
    else
      xx = [1 size(stns(i1).img,1)];
      yy = [1 size(stns(i1).img,2)];
    end
    tomo_ops(i1).qb(1) = ceil(min(xx(1:2)));
    tomo_ops(i1).qb(2) = floor(max(xx(1:2)));
    tomo_ops(i1).qb(3) = ceil(min(yy(1:2)));
    tomo_ops(i1).qb(4) = floor(max(yy(1:2)));
    
  end
  
  for i1 = 1:min(length(stns),12)
    
    stns(i1).tomops(6:9) = nan;
    
    subplot(sp(1),sp(2),i1)
    imagesc(stns(i1).img),axis xy
    imgs_smart_caxis(0.001,stns(i1).img)
    title(['Image: ',num2str(i1),' Station ',num2str(stns(i1).obs.station)])
    
  end
  
  disp('To avoid/reduce problems with errors in intensity calibrations')
  disp('one trick to use is to normalize the intensity of the projections')
  disp('to the image intensity in a central region. This way the spatial')
  disp('intensity variation will be utilized, but not the absolute intensity itself.')
  % 2 select images with normalization regions,        sso.
  renorm = in_def2('Are there any images that should be intensity normalized? (vector notation, ex: [2,3,4])',0);
  for i1 = 1:length(stns)
    
    xx = [nan nan];
    yy = [nan nan];
    if any(renorm==i1)
      
      clf
      imagesc(stns(i1).img),axis xy
      imgs_smart_caxis(0.001,stns(i1).img)
      hold on
      try
        contour('v6',stns(i1).proj,8,'k')
      catch
      end
      if ~isnan(tomo_ops(i1).qb(3))
        plot(tomo_ops(i1).qb([1 2 2 1 1]),tomo_ops(i1).qb([3 3 4 4 3]),'w')
      end
      title(['Select the ''normalization region'' for IMAGE: ', ...
	     num2str(i1)])
      
      % Disable any windowbutton down functions
      set(gcf,'windowbuttondownfcn',' ') ;
      % Get frame
      waitforbuttonpress            ;
      pnt = get(gcf,'currentpoint') ;
      xy1 = get(gca,'currentpoint') ;
      rbbox([pnt 0 0],pnt)          ;
      xy2 = get(gca,'currentpoint') ;
      
      xx  = [xy1(1,1) xy2(1,1)] ;
      yy  = [xy1(1,2) xy2(1,2)] ;
      
    end
    
    tomo_ops(i1).renorm(1) = ceil(min(xx(1:2)));
    tomo_ops(i1).renorm(2) = floor(max(xx(1:2)));
    tomo_ops(i1).renorm(3) = ceil(min(yy(1:2)));
    tomo_ops(i1).renorm(4) = floor(max(yy(1:2)));
    
  end
  
  % 6 filtertype                                       [filter2, medfilt2, proximity]
  disp('Type of spatial filtering to stabilize the reconstruction')
  disp('Available are:')
  disp('0. None')
  disp('1. Horizontal local averaging, filter2.')
  disp('2. Horizontal median filter, medfilt2.')
  disp('3. Proximity constraint, proxfilt.')
  tft = in_def2('Which filter type to use?',0);
  [tomo_ops(:).filtertype] = deal(tft);
  % 7 filterparameters
  % [filterkernel]
  if tft == 2
    tfr = in_def2('What region size to use for median filtering?',[3 3]);
  else
    tfr = in_def2('What filter kernel to use [matlab matrix]?',1);
  end
  for i2 = 1:length(stns)
    tomo_ops(i2).filterkernel = tfr;
    tomo_ops(i2).alpha = 1;
    tomo_ops(i2).disp = 'no-disp';
  end
  
else
  
  tomo_ops.tomotype = [];
  tomo_ops.qb = [];
  tomo_ops.renorm = [];
  tomo_ops.filtertype = [];
  tomo_ops.filterkernel = [];
  tomo_ops.randorder = [];
  
end % if  ( nargin == 1 )
