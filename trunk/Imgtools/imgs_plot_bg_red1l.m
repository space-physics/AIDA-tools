function out_var = imgs_plot_bg_red1l(files,PO,nrrows,rownr,nr_imgs_per_row,ff,img_reg,u1,v1,cax,outvartype)
% imgs_plot_bg_red1l - Plot a row of  background reduced images, one colorlabel
%   
% Calling:
% out_var = imgs_plot_bg_red1l(files,PO,nrrows,rownr,nr_imgs_per_row,ff,img_reg,u1,v1,cax,outvartype)
% 
%   INPUT parameters: 
%   FILES - char array of image files, full or relative path, readable 
%   PO - image pre_proc_ops see TYPICAL_PRE_PROC_OPS
%   NRROWS - total number of rows in figure
%   ROWNR - rownumber to plot in
%   RN_IMGS_PER_ROW number of images to plot in the row
%   subplot(nrrows,rownr,1:nr_imgs_per) is used to locate the
%   images
%   FF - flat-field-correction-matrix, if left empty replaced with 1
%   IMG_REG   - image region to display [xmin xmax ymin ymax], if empty
%           whole image is used.
%   U1, V1 - curve to plot over image, if left empty no curve
%   CAX   - caxis to set either [cmin cmax] for each subplot or emtpy
%   OUTVARTYPE - either 'cax' (giving max and min image intensity),
%   'img' giving an RN_IMGS_PER_ROW thick stack of images or
%   'ax_hndl' giving the handles to the subplot-axes.
%   
%   Very little or no argument checking is preformed
%
%  See also: STARCAL, CAMERA, TYPICAL_PRE_PROC_OPS



%   Copyright � 20050109 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin > 10 && ischar(outvartype)
  
  outvartp = lower(outvartype);
  
else
  
  outvartp = 'cax';
  
end

if isempty(ff)
  ff = 1;
end
% Background images: first and last in files
[data1,head1,o] = inimg(files(1,:),PO);
exptimes =  o.exptime;

t1 = o.time;%_from_header(head1);
t1 = sum(t1(4:end).*[1 1/60 1/3600]);
bg1 = data1./ff/exptimes;

[data1,head1,o] = inimg(files(end,:),PO);
exptimes =  o.exptime;
t2 = o.time;%_from_header(head1);

t2 = sum(t2(4:end).*[1 1/60 1/3600]);
bg2 = data1./ff/exptimes;
if nr_imgs_per_row > 12
  t_fntsz = 10;
else
  t_fntsz = 12;
end

for i1 = 1:nr_imgs_per_row
  
  [data1,head1,o] = inimg(files(i1+1,:),PO);
  
  exptimes =  o.exptime;
  time1 = o.time;%_from_header(head1);
  tstr = sprintf('%02d:%02d:%03.1f',time1(4:6));
  time1 = sum(time1(4:end).*[1 1/60 1/3600]);
  
  if (t2~=t1)
    data1 = data1./ff/exptimes - ( bg1 + ( bg2 - bg1)*(time1-t1)/(t2-t1));
  else
    data1 = data1./ff/exptimes - bg1;
  end
  
  ax_hndl(i1) = subplot(nrrows,nr_imgs_per_row,i1+(rownr-1)*nr_imgs_per_row);
  if ~isempty(img_reg)
    imagesc(img_reg(1):img_reg(2),img_reg(3):img_reg(4),data1(img_reg(3):img_reg(4),img_reg(1):img_reg(2))),axis xy,axis(img_reg)
  else
    imagesc(data1),axis xy
  end
  if nargin > 9
    if min(size(cax))==1
      if ~isempty(img_reg)
        imgs_smart_caxis(cax(min(i1,length(cax))),data1(img_reg(3):img_reg(4),img_reg(1):img_reg(2)));
      else
        imgs_smart_caxis(cax(min(i1,length(cax))),data1(:));
      end
    elseif prod(cax)
      caxis(cax(min(i1,size(cax,1)),:))
    end
  end
  hold on
  plot(u1,v1,'k','linewidth',1)
  axis xy
  
  title(tstr,'fontsize',t_fntsz)
  set(gca,'xticklabel',[],'yticklabel',[])
  
  if i1 == 1,
    [filepath,filename,extn] = fileparts(files(i1+1,:));
    ylabel(filename)
  end
  
  if strcmp(outvartp,'cax')
    out_var(i1,:) = caxis;
  elseif strcmp(outvartp,'img')
    out_var(:,:,i1) = data1;
  elseif strcmp(outvartp,'ax_hndl')
    out_var = ax_hndl;
  else
    warning('Unknown output variable requested')
  end
  
end

colorbar_labeled('')
