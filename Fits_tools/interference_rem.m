function img_out = interference_rem(img_in,type,method,nr_readout_regs)
% INTERFERENCE_REM - manual interference identification (and reduction)
%   IMG_OUT = INTERFERENCE_REM(IMG_IN) allows the user to identify
%   complex interference patterns in IMG_IN (class:
%   double). 
%   
%   Spatial interference frequecies are identified graphically by
%   zooming in on spikes in the log-abs display of 2-D fourier of
%   IMG_IN. Points are selected by middle-mouse-button, regions
%   showed in axis by right-mouse-button. ZOOMING in is done with
%   the left button (either klick or klick-n-drag). When all
%   interference regions are selected the return-key
%   interupts. Zooming out is done by any key except the
%   return-key.
% 
% Calling:
% img_out = interference_rem(img_in,type,method,nr_readout_regs)
% 
%   IMG_IN should be a 2-D intensity image of class double.
%   
%   IMG_OUT = INTERFERENCE_REM(IMG_IN,'type') specifies output
%   type. Available outputs are:
%     
%     'pattern' - returns the interference pattern (default)
%     'removal' - returns the image with interference removerd
%     'frequencies' returns the interference ferquencies
%     
%   IMG_OUT = INTERFERENCE_REM(IMG_IN,'removal','method') specifies
%   weighting method to use for the interference removal. Available
%   methods are: 
%     
%     'noscaling' - no wheighting of the interference pattern
%     'weighted' - weighting as suggested by Gonzales and Woods
%     'smoothed' - same as 'weighted' but weights-matrix smoothed
%   
%   IMG_OUT = INTERFERENCE_REM(...,NR_READOUT_REGS) allows
%   automatic splitting of images from imagers with separate
%   readout electronics for separate regions. Each region is then
%   treated in sequence. For a quad-read out image NR_READOUT_REGS
%   should be [2 2] and for a image that is read out in two halves
%   (img = [img_l,img_r]) NR_READOUT_REGS should be [2 1]
%   
% See also ZINPUT, FFT2
%
% Ref: Digital image processing, R. C. Gonzales, R. E. Woods,
%      1993, p 289 - 296


%   Copyright © 20050314 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if nargin < 1 || isempty(type)
  type = 'pattern'; % ['removal'| {'pattern'} | 'frequencies']
end
if nargin < 2 || isempty(method)
  method = 'noscaling'; % [{'noscaling'} | 'weighted' | 'smoothed']
end
if nargin < 3
  nr_readout_regs = [1 1];
end

img_out = img_in;

for ii = 1:nr_readout_regs(2),
  
  y_indx = [1:(size(img_in,1)/nr_readout_regs(2))]+(ii-1)*size(img_in,1)/nr_readout_regs(2);
  for jj = 1:nr_readout_regs(1),
    x_indx = [1:(size(img_in,2)/nr_readout_regs(1))]+(jj-1)*size(img_in,2)/nr_readout_regs(1);
    
    cm = fft2(img_in(y_indx,x_indx));
    mysubplot(1,1,1)
    imagesc(log(abs(cm)))
    i_regs = round(zinput);
    Cm = zeros(size(cm));
    for k = 1:size(i_regs,1)
      Cm(i_regs(k,3):i_regs(k,4),i_regs(k,1):i_regs(k,2)) = 1;
      Cm(end+2-[i_regs(k,3):i_regs(k,4)],end+2-[i_regs(k,1):i_regs(k,2)]) = 1;
    end
    Cm = Cm(1:(size(img_in,1)/nr_readout_regs(2)),1:(size(img_in,2)/nr_readout_regs(1)));
    switch type
     case 'frequencies'
      img_out(y_indx,x_indx) = Cm;
     
     case 'pattern'
      img_out(y_indx,x_indx) = ifft2(cm.*Cm);
      
     case 'removal'
      Cm = real(ifft2(cm.*Cm));
      switch method
       case 'noscaling'
        w = 1;
        
       case 'weighted'
        try
          blksiz = 64;
          if min(size(Cm)) <= 128
            blksiz = 32;
          end
          if min(size(Cm))>1023
            blksiz = 128;
          end
          
          cm = img_in(y_indx,x_indx);
          w = ( blkproc(cm.*Cm,blksiz*[1 1],'mean(x(:))') - ...
                blkproc(cm,blksiz*[1 1],'mean(x(:))').*...
                blkproc(Cm,blksiz*[1 1],'mean(x(:))') )./ ...
              ( blkproc(Cm,blksiz*[1 1],'mean(x(:).^2)') - ...
                blkproc(Cm,blksiz*[1 1],'mean(x(:))').^2);
          indxx = sort(repmat(1:size(w,2),[1 blksiz]));
          indxy = sort(repmat(1:size(w,1),[1 blksiz]));
          
          w = w(indxx(:),indxy(:));
        catch
          w = 1;
          warning('could not find: blkproc')
        end
       case 'smoothed'
        try
          blksiz = 64;
          if min(size(Cm)) <= 128
            blksiz = 32;
          end
          if min(size(Cm))>1023
            blksiz = 128;
          end
          cm = img_in(y_indx,x_indx);
          w = ( blkproc(cm.*Cm,blksiz*[1 1],'mean(x(:))') - ...
                blkproc(cm,blksiz*[1 1],'mean(x(:))').*...
                blkproc(Cm,blksiz*[1 1],'mean(x(:))') )./ ...
              ( blkproc(Cm,blksiz*[1 1],'mean(x(:).^2)') - ...
                blkproc(Cm,blksiz*[1 1],'mean(x(:))').^2);
          indxx = sort(repmat(1:size(w,2),[1 blksiz]));
          indxy = sort(repmat(1:size(w,1),[1 blksiz]));
          
          w = w(indxx(:),indxy(:));
          fltk = ones(blksiz)/blksiz^2;
          w = filter2(fltk,w,'same');
        catch
          w = 1;
          warning('could not find: blkproc')
        end
       otherwise
        w = 1;
      end
      img_out(y_indx,x_indx) = img_in(y_indx,x_indx) - w.*Cm;
      
     otherwise
      error(['unknown output type requested: ',type])
    end
    
  end
  
end
