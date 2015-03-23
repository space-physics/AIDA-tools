function Img = bad_pixel_fix(Img,bad_p_map)
% BAD_PIXEL_FIX - simple badpixel korrection function works on
% single lines and columns. (Ah, the power of indexing and sparse
% matrices!) After repeated passes larger blocks with badpixels are
% reduced but not completely corrected. BG 2001-08-27
%   
% Calling:
% Img = bad_pixel_fix(Img,bad_p_map)

% how to create BAD_P_MAP from table.


%   Copyright © 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

Img = Img;

bpmp = bad_p_map';
bad_p_v = bpmp(:);
i1 = find(bad_p_v);
Img = Img';
Img(i1) = Img(min(i1+1,length(Img(:))))/2+Img(max(i1-1,1))/2;
Img = Img';

bad_p_v = bad_p_map(:);
i1 = find(bad_p_v);
Img(i1) = Img(min(i1+1,length(Img(:))))/2+Img(max(i1-1,1))/2;
