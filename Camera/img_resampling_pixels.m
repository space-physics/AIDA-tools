function [uI2,vI2] = img_resampling_pixels(imgsize1,imgsize2,optp1,optp2)
% IMG_RESAMPLING_PIXELS - resampling coordinates for one image to match look directions of another
%   
% Calling:
%  [uI2,wI2] = img_resampling_pixels(imgsize1,imgsize2,optp1,optp2)
% Input:
%  imgsize1 - size of image 1 (the image to take look-directions
%             for) [sy1, sx1] integer array
%  imgsize2 - size of image 2 (the image to match look-directions
%             of) [sy2, sx2] integer array
%  optp1    - optical parameters for image 1, double array [1 x 9]
%  optp2    - optical parameters for image 2, double array [1 x 9]
%  For OPTP1 and OPTP2 see CAMERA_MODEL and INV_CAMERA_MODEL
% Output:
%  uI2      - horizontal pixel coordinates, double array with size
%             [sy2, sx2] 
%  wI2      - vertical pixel coordinates, double array with size
%             [sy2, sx2] 
%  Resampling of image2 is then done with for example: 
%   CImg2 = interp2(img2,uI2,wI2); 
%   or
%   CImg2 = ASK_image_c(img2,uI2,wI2)


%   Copyright � 20131018 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

% Initialize all u,v, az1, az1, ua3, va3 to the right dimensions
[u1,v1] = meshgrid(1:imgsize1(2),1:imgsize1(1));
az1 = zeros(imgsize1);
ze1 = zeros(imgsize1);
uI2 = zeros(imgsize2);
vI2 = zeros(imgsize2);

% for pixels [u,v] in image1, calculate the corresponding look-directions:
[az1(:),ze1(:)] = inv_project_directions(u1(:),v1(:),...
                                         ones(imgsize1),...
                                         [0 0 0],...
                                         optp1(9),optp1,...
                                         [0 0 1],1,eye(3));
% For those look-directions calculate the corresponding pixels in img2:
[uI2(:),vI2(:)] = project_directions(az1(:),ze1(:),optp2,optp2(9),imgsiz2);
