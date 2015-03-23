function out_var = imgs_plot(files,PO,nrrows,rownr,nr_imgs_per_row,ff,img_reg,u1,v1,cax,outvartype)
% imgs_plot - Plot a row of images
%   
% Calling:
% out_var = imgs_plot(files,PO,nrrows,rownr,nr_imgs_per_row,ff,img_reg,u1,v1,cax,outvartype)
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
%   OUTVARTYPE - either 'cax' (giving max and min image intensity)
%   or 'img' giving an RN_IMGS_PER_ROW thick stack of images
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

for i = 1:nr_imgs_per_row
  
  [data1,head1,o] = inimg(files(i,:),PO);
  exptimes =  o.exptime;
  data1 = data1/exptimes;
  
  time1 = o.time;%_from_header(head1);
  tstr = sprintf('%02d:%02d:%02d',time1(4:6));
  xlstr = sprintf('%d A',o.filter);
  %TBR?: time1 = sum(time1(4:end).*[1 1/60 1/3600]);
  
  subplot(nrrows,nr_imgs_per_row,i+(rownr-1)*nr_imgs_per_row)
  if ~isempty(img_reg)
    imagesc(img_reg(1):img_reg(2),img_reg(3):img_reg(4),data1(img_reg(3):img_reg(4),img_reg(1):img_reg(2))),axis xy,axis(img_reg)
  else
    imagesc(data1),axis xy
  end
  if nargin > 9
    if strcmp(cax,'auto')
      caxis auto
    elseif min(size(cax))==1
      if ~isempty(img_reg)
        imgs_smart_caxis(cax(min(i,length(cax))),data1(img_reg(3):img_reg(4),img_reg(1):img_reg(2)));
      else
        imgs_smart_caxis(cax(min(i,length(cax))),data1(:));
      end
    elseif numel(cax) %was: prod(size(cax))
      caxis(cax(min(i,size(cax,1)),:))
    end
  end
  hold on
  plot(u1,v1,'k','linewidth',1)
  axis xy 
  title(tstr,'fontsize',12)
  xlabel(xlstr,'fontsize',12)
  set(gca,'xticklabel',[],'yticklabel',[])
  
  colorbar_labeled('')
  if i == 1,
    [filepath,filename,extn] = fileparts(files(i+1,:));
    ylabel(filename)
  end
  
  if strcmp(outvartp,'cax')
    out_var(i,:) = caxis;
  elseif strcmp(outvartp,'img')
    out_var(:,:,i) = data1;
  else
    warning('Unknown output variable requested')
  end
  
end
