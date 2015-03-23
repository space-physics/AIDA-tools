function Vem = tomo_3Dfiltering(VemIn,tomo_ops)
% TOMO_3DFILTERING - 
%   

%   Copyright © 20120330 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


Vem = VemIn;
% Here, after the itteration, we do filtering to suppress noise
switch tomo_ops(1).filtertype
 case 1 % horizontal 2D averaging
  for k = 1:size(Vem,3),
    Vem(:,:,k) = conv2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel,'same');
  end
 case 2 % horizontal 2D median
  for k = 1:size(Vem,3),
    Vem(:,:,k) = medfilt2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel);
  end
 case 3 % proximity filtering
  fiel_align_int = sum(Vem,3);
  filt_f_a_i = conv2(fiel_align_int,tomo_ops(1).filterkernel,'same');
  for k = 1:size(Vem,3),
    Vem(:,:,k) = conv2(squeeze(Vem(:,:,k)),tomo_ops(1).filterkernel,'same').*fiel_align_int./filt_f_a_i;
  end
  %Infindx = find(~isfinite(Vem(:)));
  Vem(~isfinite(Vem(:))) = 0;
 case 4 % proximity sharpening, Lucy-Richardson deconvolution-like
  fiel_align_int = sum(Vem,3);
  %filt_f_a_i = conv2(fiel_align_int,tomo_ops(1).filterkernel,'same');
  deconvd_f_a_i = imgs_deconv_crude(fiel_align_int,tomo_ops(1).filterkernel,1,1);
  for k = 1:size(Vem,3),
    Vem(:,:,k) = squeeze(Vem(:,:,k)).*deconvd_f_a_i./fiel_align_int;
  end
  %Infindx = find(~isfinite(Vem(:)));
  Vem(~isfinite(Vem(:))) = 0;
 otherwise
  % no filtering
end % switch filtertype

