function Int = interf_filt_shape(c_wl,d_wl,theta_max,wl_out)
% INTERF_FILT_SHAPE - calculate pass-band of interference filter
% (optical narrow band-pass filter) when light is constant within a
% cone with top angle THETA_MAX,
% 
% Calling:
% Int = interf_filt_shape(c_wl,d_wl,theta_max,wl_out)
%


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

[wl,theta] = meshgrid(wl_out,linspace(0,theta_max,100));

filter0 = exp(-(wl-c_wl.*(1-sin(theta).^2/2.^2).^.5).^4/(d_wl/2).^4);
Int = sum(filter0.*sin(theta).*gradient(theta')');
