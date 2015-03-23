function Img = bias_correction(Img,obs)
% BIAS_CORRECTION - Corrects zero level bias from ALIS ccd images
% 
% Calling:
%   Img = bias_correction(Img,obs)
% 
% INPUT:
%   IMG - ALIS image to be corrected
%   OBS - obs-structure as returned from TRY_TO_BE_SMART
% 
% See also: INIMG, TRY_TO_BE_SMART


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

cam_nr = obs.camnr;
binning_factor = 1024./size(Img);

bias = 0;
try
  load(fullfile(['ccd',num2str(cam_nr)],['bias_',num2str(binning_factor(1)),'x',num2str(binning_factor(1)),'.mat']))
catch
  try
    load(fullfile(['ccd',num2str(cam_nr)],['bias_',num2str(binning_factor(1)/2),'x',num2str(binning_factor(1)/2),'.mat']))
    bias = bias(1:2:end,1:2:end)+bias(2:2:end,1:2:end)+bias(1:2:end,2:2:end)+bias(2:2:end,2:2:end);
  catch
  end
end

Img = Img - bias;
