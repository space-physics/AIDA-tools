function ph = aidathumb_load_n_show(filename,PO,figHandle)
% LOAD_N_SHOW - Callback wrapper function for loading and
% displaying selected image. Called by Imthumb.
% 
% Calling:
%   ph = aidathumb_load_n_show(filename,PO,figHandle)
% Input:
%   filename  - imreadable filename to image to display
%   figHandle - handle figure to display image in


%   Copyright © 20140122 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later
Dops = get(gcf,'userdata');

[im,h,obs] = inimg(filename,PO);


%try
  % Regardless of if these fail
  switch lower(Dops.ImToolFcn)
   case 'imthumbimtool'
    figure(figHandle);
    Ph = aidathumbImTool(im,Dops);% replace with: imtool(im) if that's prefered.
    th = title(filename,'fontsize',Dops.fontsizes);
    set(th,'interpreter','none')
   case 'imtool'
    imtool(im)
    title(filename,'fontsize',Dops.fontsizes)
   otherwise
    figure(figHandle);
    Ph = imagesc(im);
    title(filename,'fontsize',Dops.fontsizes)
    
  end
  
%catch
%  % The full image will be displayed
%  disp(['The prefered ImToolFcn (',Dops.ImToolFcn,') failed to launch'])
%  figure(figHandle);
%  Ph = imagesc(im);
%  title(filename,'fontsize',Dops.fontsizes)
%end
if nargout
  ph = Ph;
end
