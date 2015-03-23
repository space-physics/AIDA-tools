function OK = alis_overviewmovie(moviename,Filenames,POs,mOpts)
% ALIS_OVERVIEWMOVIE - Makes movies of images in files
%   
% Calling:
%   OK = alis_overviewmovie(Filenames)
% Input:
%   Filenames - cell array of string-matrices with filenames from
%               stations 
%   POs       - struct array with pre-processing options

dOPTS.filters = [4278,5577,6300,8446];
dOPTS.imregs = [];
if nargin == 0
  OK = dOPTS;
  return
end
OK = 0;

if nargin > 3 & ~isempty(mOpts)
  dOPTS = catstruct(dOPTS,mOpts);
end

set(gcf,'visible','off') % To free the computer screen

mov = avifile(moviename);
set(gcf,'name','On the "Silver screen" tonight...');
pause(2)
nrstns = length(Filenames);
fnr = length(dOPTS.filters);


% TODO fix this so that it works "properly" even for asyncronous
%      exposure sequences...
for i2 = 1:max([size(Filenames{1},1),size(Filenames{2},1)]),
  
  for j1 = 1:nrstns,
    
    [d,h,o] = inimg(Filenames{j1}(i2,:),POs(j1));
    [emi] = alis_filter_fix(o.filter);
    switch emi
     case 4278
      sp_r = 1;
     case 5577
      sp_r = 2;
     case 6300
      sp_r = 3;
     case 8446
      sp_r = 4;
     otherwise
      sp_r = [];
    end
    if ~isempty(sp_r) %subplot(fnr,snr,(i2-1)*(snr)+i1)
      mysubplot(fnr,nrstns,nrstns*(sp_r-1)+j1)
      if isempty(dOPTS.imregs)
        imagesc(d),axis xy,imgs_smart_caxis(0.005,d(:));
      else
        reg = dOPTS.imregs(min(j1,size(dOPTS.imregs,1)),:);
        imagesc(d(reg(3:4),reg(1:2))),axis xy,imgs_smart_caxis(0.005,d(:));
      end
      if j1 == 1
        ylabel(sprintf('%d A',emi),'fontsize',14)
      end
      set(gca,'xticklabel','','yticklabel','')
      t_str = sprintf('%d %02d:%02d:%02d',o.station,o.time(4:6));
      text(10,20,t_str,'fontsize',10,'color',0.97*[1 1 1])
    end
  end
  %F = getframe(gcf);
  mov = addframe(mov,gcf);
  
end
mov = close(mov);
OK = 1;
set(gcf,'visible','on') % To free the computer screen
