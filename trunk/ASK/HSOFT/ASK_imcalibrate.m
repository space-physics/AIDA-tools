function img_out = ASK_imcalibrate(img_in)
% ASK_IMCALIBRATE - scale the images to Rayleighs
%   
% Calling:
%   img_out = ASK_imcalibrate(img_in,d_field,fmd_field)
% Input:
%   img_in    - Input image, uncalibrated
%   d_field   - Dark/background image
%   fmd_field - flatfield/sensitivity image
% Output:
%   img_out - (img_in - d_field)./fmd_field;
%
% Written to mimic imcalibrate.pro
%
% Function def was: function img_out = ASK_imcalibrate(img_in)%,d_field,fmd_field)

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global imcal % WITH: d_field, fmd_field

img_out = (img_in - imcal.d_field)./imcal.fmd_field;
