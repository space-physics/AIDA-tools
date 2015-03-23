function [img,obs] = inputall(filename)
% [rbild,gbild,bbild,tid,station,optpar] = inputall(filename,stardir,make_opt)
% 
% INPUTALL reads an image FILENAME. STARDIR is the
%    path to where starcaltoolkit is installed. MAKE_OPT tells 
%    wether to build OPTPAR or not.
%    
%    See also IMREAD, INPUTFITS2

%   Copyright © 19970907 Bjorn Gustavsson<bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% global bx by bxy

try
  img = imread(filename);
  [p,n,ext] = fileparts(filename);
  obs = imfinfo(filename);
  if ndims(img)==3
    try
      img = rgb2hsv(img);
      img = double(img(:,:,3));
    catch
      img = squeeze(sum(double(img),3));
    end
  else
    img = double(img);
  end
  if strcmp(ext,'.png')
    %img = 255-img;
  end
catch
  obs.empty = 1;
who
img = load(filename);
end

%bxy = size(img);
%bx = bxy(2);
%by = bxy(1);
