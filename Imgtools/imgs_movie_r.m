function [M,Tstrs,caxout,exptimes,wl] = imgs_movie_r(files,reg,cax,opptp,PREPROC_OPS,movie_ops,avi_ops)
% imgs_movie_r - produce a matlab movie M from a series of image files.
%   Additional output is TSTRS - observation times of the images - as
%   best it can, CAXOUT result from caxis for each image, EXPTIMES -
%   exposuretimes for the images.
%   
% Calling:
% [M,Tstrs,caxout,exptimes] = imgs_movie_r(files,reg,cax,opptp,PREPROC_OPS,movie_ops,avi_ops)
% 
%   INPUT parameters: 
%   FILES - char array of image files, full or relative path, readable 
%   REG   - image region to display [xmin xmax ymin ymax], if empty
%           whole image is used.
%   CAX   - caxis to set either [cmin cmax] or 'auto'
%   OPPTP - optpar, see STARCAL, CAMERA
%   PREPOC_OPS - image pre_proc_ops see TYPICAL_PRE_PROC_OPS
%   MOVIE_OPS - options controlling the movie, currently only
%               checks movie_ops.gcfa see if current figure or
%               current axis should be stored, default is gcf.
%   avi_ops - cell array to send to avifile controlling the avi
%             output. See avifile for details.
% 
%   Very little or no argument checking is preformed
%
%  See also: STARCAL, CAMERA, TYPICAL_PRE_PROC_OPS


%   Copyright © 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

try
  get_fig = movie_ops.gcfa;
catch 
  get_fig = 1;
end
if nargin < 7
  avi_ops = {};
end
if isequal(get(gcf,'visible'),'on')
  
  if get_fig
    M = moviein(size(files,1),gcf);
  else
    M = moviein(size(files,1),gca);
  end
  startindx = size(files,1);
  stopindx = 1;
  stepdir = -1;
  
else
  
  tmpname = ['/tmp/alis_mov',num2str(rand(1),'%8f'),'.avi'];
  if ~isempty(avi_ops)
    M = avifile(tmpname,avi_ops);
  else
    M = avifile(tmpname);
  end
  startindx = 1;
  stopindx = size(files,1);
  stepdir = 1;
  
end

Tstrs = '';
if nargin >= 4 & length(opptp) > 8
  ff = ffs_correction2([PREPROC_OPS.outimgsize].*[1 1],opptp,opptp(9));
else
  ff = 1;
end


for i = startindx:stepdir:stopindx,
  
  if ischar(files)
    [data1,head1,obs1] = inimg(files(i,:),PREPROC_OPS);
  else
    [data1,head1,obs1] = inimg(files(i).name,PREPROC_OPS);
  end
  deltah = mean(data1(end/2,:)-data1(end/2+1,:));
  data1(1:end/2,:) = data1(1:end/2,:) - deltah/2;
  data1((1+end/2):end,:) = data1((end/2+1):end,:) + deltah/2;
  
  deltav = mean( data1(:,end/2) - data1(:,end/2+1));
  data1(:,1:end/2) = data1(:,1:end/2) - deltav/2;
  data1(:,(1+end/2):end) = data1(:,(end/2+1):end) + deltav/2;
  
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
    wl(i) = [nan];
  end    
  data1 = 1000*data1./ff/exptimes(i);
  if ~isempty(reg)
    imagesc(reg(1):reg(2),reg(3):reg(4),data1(reg(3):reg(4),reg(1):reg(2))),axis xy,axis(reg)
    data1 = data1(reg(3):reg(4),reg(1):reg(2));
  else
    imagesc(data1),axis xy
  end
  caxout(i,:) = caxis;
  
  tstrs = sprintf('%.2d:%.2d:%.2d',obs1.time(4:6));
  if length(cax)==1
    imgs_smart_caxis(cax,data1);
    caxout(i,:) = caxis;
    title(tstrs,'fontsize',18)
  else
    caxis(cax),title(tstrs,'fontsize',18)
  end
  drawnow
  if isequal(get(gcf,'visible'),'on')
    
  if get_fig
    M(:,i) = getframe(gcf);
  else
    M(:,i) = getframe(gca);
  end
    
  else
    
  if get_fig
    M = addframe(M,gcf);
  else
    M = addframe(M,gca);
  end
    
  end
  
end

if isequal(get(gcf,'visible'),'off')
  
  M = close(M);
  whos M
  M = aviread(tmpname);
  whos M
  unix(['ls -l ',tmpname,';rm ',tmpname]);
  
end
