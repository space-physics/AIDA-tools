function RGB = sk_make_rgb(BSNR)
% SK_MAKE_RGB - transform Pulkovo spectra into RGB triplet
%   
% Calling:
%  RGB = sk_make_rgb(BSNR)


%   Copyright © 2005 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


Lb = [395.3125
      400.0000
      411.9792
      439.0625
      450.0000
      460.9375
      489.0625
      512.3762
      535.6436];
eye_b = [0.0212
         0.0377
         0.1274
         0.9552
         0.9835
         0.9316
         0.3042
         0.0896
         0.0071];
Lg = [423.9583
      470.8333
      495.3125
      517.8218
      544.0594
      578.4946
      600.0000
      630.0971
      658.3333];
eye_g = [0.0118
         0.0967
         0.2241
         0.4764
         0.6627
         0.4481
         0.2476
         0.0377
         0.0047];
Lr = [405.7292
      439.0625
      467.7083
      500.4950
      534.6535
      565.0538
      587.0968
      618.4466
      641.2621
      671.6667
      701.6667];
eye_r = [0.0142
         0.0401
         0.0189
         0.1014
         0.3632
         0.5212
         0.5637
         0.3986
         0.1863
         0.0472
         0.0047];

[wavelengths,energyfluxes] = getspec(BSNR,0);
i_max = find(diff(wavelengths)<0);
if min(size(i_max)) == 0
  i_max = length(energyfluxes);
end

rgb{1} = interp1(Lr,eye_r,wavelengths(1:i_max),'pchip',0).*energyfluxes(1:i_max);
rgb{1}(~isfinite(rgb{1})) = 0;
rgb{2} = interp1(Lg,eye_g,wavelengths(1:i_max),'pchip',0).*energyfluxes(1:i_max);
rgb{2}(~isfinite(rgb{2})) = 0;
rgb{3} = interp1(Lb,eye_b,wavelengths(1:i_max),'pchip',0).*energyfluxes(1:i_max);
rgb{3}(~isfinite(rgb{3})) = 0;

RGB = [sum(rgb{1}),sum(rgb{2}),sum(rgb{3})];
RGB = RGB/max(RGB);
