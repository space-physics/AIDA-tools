function image_out = ASK_image_c(image_in,i_out,j_out)
% ASK_IMAGE_C - reinterpolate image nearest neighbour style.
%   
% Calling:
%   image_out = ASK_image_c(image_in,i_out,j_out)
% Input
%  image_in - The input image
%  i_out - from remap
%  j_out - from remap
% Outputs:
%  image_out - The image with remapped image
%  
% written to mimic image_c.pro

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

image_out = interp2(image_in,i_out,j_out,'nearest');


