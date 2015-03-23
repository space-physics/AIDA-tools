function [img_head,img_out] = read_pikeraw(filename,img_size,format)
% READ_PIKERAW - read pike raw 2-byte images
%   
% Calling:
%  [img_head,img_out] = read_pikeraw(filename,img_size)
% Input:
%  filename - char array with filename, either full or relative path
%  img_size - [SY, SX] image sizes,
%  format   - data format, defaults to uint16, See FREAD for
%             possible values.
% Output:
%  IMG_HEAD - empty array with(out) image header with image
%             meta-data, output to comply with READ_IMG and INIMG
%  IMG_OUT  - image array [ SY x SX ], double.
% 
%
%   Copyright © 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 3
  format = 'uint16';
end

fil = fopen(filename, 'r', 'b');
img_out = fread(fil, format);
fclose(fil);
img_out = double(reshape(img_out,img_size)');
img_head = [];
