function imgout = rem_vert_interference(imgin,notch_lines,nrregs)
% REM_VERT_INTERFERENCE - Notch filter to remove vertical
% interferens from images.
%   
% Calling:
% imgout = rem_vert_interference(imgin,notch_lines,nrregs)
% 
% INPUT:
%   IMGIN - 2-D array with interference pattern in teh vertical
%           direction.
%   NOTCH_LINES - frequencies to be removed (pixel index in
%                 fft-plane). 
%   NRREGS - 2 for images with 2 separate readout channels,
%            interference pattern then not continous over column


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ( nrregs==1 )
  
  fk = fft(imgin);
  fk(notch_lines,:) = 0;
  fk(end-notch_lines+2,:) = 0;
  imgout = real(ifft(fk));
  
elseif ( nrregs == 2 )
  
  [imgin,bg] = detrend(imgin,'linear',round([size(imgin,1)/2 size(imgin,1)/2+1]));
  fk = fft(imgin(1:end/2,:));
  fk(notch_lines,:) = 0;
  fk(end-notch_lines+2,:) = 0;
  imgout = real(ifft(fk));
  fk = fft(imgin(end/2+1:end,:));
  fk(notch_lines,:) = 0;
  fk(end-notch_lines+2,:) = 0;
  imgout = [imgout;real(ifft(fk))];
  imgout = imgout+bg;
  
end
