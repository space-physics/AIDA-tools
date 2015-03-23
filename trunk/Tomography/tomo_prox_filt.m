function Vem = tomo_prox_filt(Vem,fK)
% TOMO_PROX_FILT - Proximity filtering along 3rd dimension
%   
% Calling:
%   Vem = tomo_prox_filt(Vem,fK)
%
% Input:
%   Vem - 3-D array of auroral intensities.
%   fK  - 2-D filter kernel for horisontal filtering.
%
% Output:
%   Vem - proximity filtered 3-D array.



%   Copyright © 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

fiel_align_int = sum(Vem,3);
filt_f_a_i = conv2(fiel_align_int,fK,'same');
for k = size(Vem,3),
  Vem(:,:,k) = conv2(squeeze(Vem(:,:,k)),fK,'same').*fiel_align_int./filt_f_a_i;
end

Vem(~isfinite(Vem(:))) = 0;

