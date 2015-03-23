function [M] = alis_imgs_movie_rgb(files,reg,cax,opptp,PREPROC_OPS,rgbFilters)
% ALIS_IMGS_MOVIE_RGB - produce a matlab movie M from a series of image files.
%   The frames are truecolor made up from 6300/8446 as the red
%   image plane, 5577 as the green and 4278 A as the blue. The
%   different image planes will be exposed at various times.
% 
% Calling:
%  [M] = alis_imgs_movie_rgb(files,reg,cax,opptp,PREPROC_OPS,rgbFilters)
% 
%   INPUT parameters: 
%   FILES - char array of image files, full or relative path, readable 
%   REG   - image region to display [xmin xmax ymin ymax], if empty
%           whole image is used.
%   CAX   - caxis to set either [cmin cmax] or 'auto'
%   OPPTP - optpar, see STARCAL, CAMERA
%   PREPOC_OPS - image pre_proc_ops see TYPICAL_PRE_PROC_OPS
%   RGBFILTERS - Filter_key to RGB mapping
% 
%   Very little or no argument checking is preformed
%
%  See also: STARCAL, CAMERA, TYPICAL_PRE_PROC_OPS

%   Copyright © 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if isequal(get(gcf,'visible'),'on')
  
  M = moviein(size(files,1),gcf);
  startindx = size(files,1);
  stopindx = 1;
  stepdir = -1;
  
else
  
  tmpname = ['/tmp/alis_mov',num2str(rand(1),'%8f'),'.avi'];
  M = avifile(tmpname);
  startindx = 1;
  stopindx = size(files,1);
  stepdir = 1;
  
end
if ~isstr(rgbFilters)
  PREPROC_OPS.img_histeq = max(100,PREPROC_OPS.img_histeq);
else
  PREPROC_OPS.img_histeq = 0;
end

Tstrs = '';
if nargin >= 4 & length(opptp) > 8
  ff = ffs_correction2([PREPROC_OPS.outimgsize].*[1 1],opptp,opptp(9));
else
  ff = 1;
end
if ischar(files)
  [data1,head1,obs1] = inimg(files(1,:),PREPROC_OPS);
else
  [data1,head1,obs1] = inimg(files(1).name,PREPROC_OPS);
end
img = zeros([size(data1) 3]);

for i = startindx:stepdir:stopindx,
  
  if ischar(files)
    [data1,head1,obs1] = inimg(files(i,:),PREPROC_OPS);
  else
    [data1,head1,obs1] = inimg(files(i).name,PREPROC_OPS);
  end
% $$$   deltah = mean(data1(end/2,:)-data1(end/2+1,:));
% $$$   data1(1:end/2,:) = data1(1:end/2,:) - deltah/2;
% $$$   data1((1+end/2):end,:) = data1((end/2+1):end,:) + deltah/2;
% $$$   
% $$$   deltav = mean( data1(:,end/2) - data1(:,end/2+1));
% $$$   data1(:,1:end/2) = data1(:,1:end/2) - deltav/2;
% $$$   data1(:,(1+end/2):end) = data1(:,(end/2+1):end) + deltav/2;
  
  titlestr = sprintf('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d',obs1.time);
  Tstrs = str2mat(Tstrs,titlestr);
  
  efact = 1;
  if obs1.exptime<100
    efact = 1000;
  end
  exptimes(i) =  obs1.exptime*efact;
  if ~isempty(obs1.filter)
    wl(i) = obs1.filter;
  else
    wl(i) = nan;
  end    
  data1 = 1000*data1./ff/exptimes(i);
  
  if ~isstr(rgbFilters)
    switch obs1.filter
     case rgbFilters(1)
      img(:,:,1) = 0;
      rgbf = 6300;
     case rgbFilters(2)
      img(:,:,2) = 0;
      rgbf = 5577;
     case rgbFilters(3)
      img(:,:,3) = 0;
      rgbf = 4278;
     otherwise
      rgbf = nan;
    end
    if ~isnan(rgbf)
      img = img + alis_img2rgb(data1,rgbf);
    end
    if ~isempty(reg)
      imagesc(reg(1):reg(2),reg(3):reg(4),img(reg(3):reg(4),reg(1):reg(2),:)),axis xy,axis(reg)
      data1 = data1(reg(3):reg(4),reg(1):reg(2));
    else
      imagesc(img),axis xy
    end
  elseif strcmp(rgbFilters,'E0')
    switch obs1.filter
     case 8446
      img(:,:,1) =data1;
     case 6300
      img(:,:,2) = data1;
     case 4278
      img(:,:,3) = data1;
     otherwise
    end
    [imgE0] = imgs_spec_ratio2E0fO(img(:,:,3),img(:,:,2),img(:,:,1));
    if ~isempty(reg)
      imagesc(reg(1):reg(2),reg(3):reg(4),imgE0(reg(3):reg(4),reg(1):reg(2))),axis xy,axis(reg)
      data1 = imgE0(reg(3):reg(4),reg(1):reg(2));
    else
      imagesc(img),axis xy
    end
  end
  caxout(i,:) = caxis;
  
  tstrs = sprintf('%.2d:%.2d:%.2d',obs1.time(4:6));
  title(tstrs,'fontsize',18)
  drawnow
  if isequal(get(gcf,'visible'),'on')
    
    M(:,i) = getframe(gcf);
    
  else
    
    M = addframe(M,gcf);
    
  end
  
end

if isequal(get(gcf,'visible'),'off')
  
  M = close(M);
  whos M
  M = aviread(tmpname);
  whos M
  unix(['ls -l ',tmpname,';rm ',tmpname]);
  
end
