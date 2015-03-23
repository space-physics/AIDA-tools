function [Img] = replace_border(Img)
% REPLACE_BORDER - replaces the outermost border
%   with second line from edges.
% 
% Calling:
% [Img] = replace_border(Img)
% 
% INPUT:
%   Img 2-D matrix


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

Img = Img;
Img(1,:) = Img(2,:);
Img(:,1) = Img(:,2);
Img(end,:) = Img(end-1,:);
Img(:,end) = Img(:,end-1);
