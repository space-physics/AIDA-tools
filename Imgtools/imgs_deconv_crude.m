function img_out = imgs_deconv_crude(img_in,psf,damp_level,edge_t_scale)
% imgs_deconv_crude - Deconvolution, amplitude cut-off method
% The (high) frequency components of IMG_IN will not be amplified
% if abs(fft(PSF)) < DAMP_LEVEL. EDGE_T_SCALE - factor to scale the
% edge-tapering size with
%   
% CALLING:
% img_out = imgs_deconv_crude(img_in,psf,damp_level)
%
% INPUT:
%   IMG_IN - intensity image, (double)
%   PSF - point spread function to use for de-debluring
% DAMP_LEVEL - for amplitudes below this there will be no
%              amplification.
% EDGE_T_SCALE - scaling factor for size of edge-tapering region,
%                fairly useless?
%
% See also: DECONVBLIND, DECONVLUCY, DECONVWNR, DECONVREG


%   Copyright © 20050115 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


PSF = psf/sum(psf(:));
img_out = img_in.*(conv2(img_in./conv2(img_in,PSF,'same'),PSF,'same'));
img_out = img_out.*(conv2(img_in./conv2(img_out,PSF,'same'),PSF,'same'));
img_out(1,:) = img_in(1,:);
img_out(end,:) = img_in(end,:);
img_out(:,1) = img_in(:,1);
img_out(:,end) = img_in(:,end);
