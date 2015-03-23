function [Vem,q] = tomo_prox_sharpen(Vem,fK)
% TOMO_PROX_SHARPEN - Proximity sharpening filter,
%  along 3rd dimension
%   
% Calling:
%   Vem = tomo_prox_sharpen(Vem,fK)
%
% Input:
%   Vem - 3-D array of auroral intensities.
%   fK  - 2-D filter kernel for horisontal filtering.
%
% Output:
%   Vem - proximity filtered 3-D array.


%   Copyright © 2010 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

fiel_align_int = sum(Vem,3);
filt_f_a_i = conv2(fiel_align_int,fK,'same');
for k = size(Vem,3),
  Vem(:,:,k) = squeeze(Vem(:,:,k)).*deconvlucy(fiel_align_int,fK,3)./fiel_align_int;
end
q = fiel_align_int./filt_f_a_i;
%Infindx = find(~isfinite(Vem(:)));
%Vem(Infindx) = 0;

Vem(~isfinite(Vem(:))) = 0;
