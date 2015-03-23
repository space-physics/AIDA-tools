function imgout = vert_interference_pattern(imgin,notch_lines,nrregs)
% VERT_INTERFERENCE_PATTERN - Isolates vertical interferens from images.
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
%
% OUTPUT:
%   IMGOUT - interference pattern
%  

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ( nrregs==1 )
  
  fk = fft(imgin);
  fp = 0*fk;
  fp(notch_lines,:) = fk(notch_lines,:);
  fp(end-notch_lines+2,:) = fk(end-notch_lines+2,:);
  imgout = real(ifft(fp));
  
elseif ( nrregs == 2 )
  
  [imgin] = detrend(imgin,'linear',round([size(imgin,1)/2 size(imgin,1)/2+1]));
  fk = fft(imgin(1:end/2,:));
  fp = 0*fk;
  fp(notch_lines,:) = fk(notch_lines,:);
  fp(end-notch_lines+2,:) = fk(end-notch_lines+2,:);
  imgout = real(ifft(fp));
  fk = fft(imgin(end/2+1:end,:));
  fp = 0*fk;
  fp(notch_lines,:) = fk(notch_lines,:);
  fp(end-notch_lines+2,:) = fk(end-notch_lines+2,:);
  imgout = [imgout;real(ifft(fp))];
  
end
