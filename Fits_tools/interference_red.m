function img_out = interference_red(img_in,lines,columns,points)
% INTERFERENCE_RED - Interference reduction
%   
% Calling:
% img_out = interference_red(img_in,lines,columns,points)
% 
% Input:
%   IMG_IN - 2-D double array from which interference is to be
%            removed.
%   LINES - Line-nr array [(1xN) or (Nx1)] for lines in the
%           fft-plane to be removed 
%   COLUMNS - column-nr array for columns in the fft-plane to be
%             removed.
%   POINTS - point coordinates for frquencies to be removed (not yet?)
% 
% Obsolete, replaced by INTERFERENCE_REM_RAUTO
% See also


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


if numel(lines) > 0
  % Mask selected lines in the Fourier transform of the image...
  fk = fft(img_in(1:end/2,1:end/2));
  fk(lines,:) = 0;
  ifk = real(ifft(fk));
  img_in(1:end/2,1:end/2) = ifk;
  % ...quadrant...
  fk = fft(img_in(end/2+1:end,1:end/2));
  fk(lines,:) = 0;
  ifk = real(ifft(fk));
  img_in(end/2+1:end,1:end/2) = ifk;
  % ...by...
  fk = fft(img_in(1:end/2,end/2+1:end));
  fk(lines,:) = 0;
  ifk = real(ifft(fk));
  img_in(1:end/2,end/2+1:end) = ifk;
  %  ...quadrant
  fk = fft(img_in(end/2+1:end,end/2+1:end));
  fk(lines,:) = 0;
  ifk = real(ifft(fk));
  img_in(end/2+1:end,end/2+1:end) = ifk;
  
end

if nargin > 3 && numel(columns)
  % do the same thing with the interference-dominated columns...
  fk = fft(img_in(1:end/2,1:end/2)');
  fk(lines,:) = 0;
  ifk = real(ifft(fk'));
  img_in(1:end/2,1:end/2) = ifk;
  % ...quadrant...
  fk = fft(img_in(end/2+1:end,1:end/2)');
  fk(lines,:) = 0;
  ifk = real(ifft(fk'));
  img_in(end/2+1:end,1:end/2) = ifk;
  % ...by...
  fk = fft(img_in(1:end/2,end/2+1:end)');
  fk(lines,:) = 0;
  ifk = real(ifft(fk'));
  img_in(1:end/2,end/2+1:end) = ifk;
  % ...quadrant.
  fk = fft(img_in(end/2+1:end,end/2+1:end)');
  fk(lines,:) = 0;
  ifk = real(ifft(fk'));
  img_in(end/2+1:end,end/2+1:end) = ifk;
  
end
img_out = img_in;
