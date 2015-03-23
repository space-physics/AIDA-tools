function [img_head,img_out] = read_torsten_raw(filename)
% READ_TORSTEN_RAW - read Torsten Inge I Aslaksen's raw 2-byte images
%   


%   Copyright © 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

fil = fopen(filename, 'r', 'b');
img_out = fread(fil, '*uint16');
fclose(fil);
img_out = double(reshape(img_out, 1388, 1038)');
img_head = [];

