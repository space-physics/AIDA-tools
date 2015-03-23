function [Iout,Ibg] = img_reg_bg_red(Iin,reg4bg,method,method_args)
% IMG_REG_BG_RED - removal of estimated background in image region
%   The background is estimated from "in-painting" of the image
%   values i the frame of the region REG4BG.
%
% Calling:
%   [Iout,Ibg] = img_reg_bg_red(Iin,reg4bg)
% Input:
%   Iin - input image [n x m], Assumed double, no type-checking done
%   reg4bg - corners of the background region [x_min, x_max, y_min, y_max]
%   method - selection of estimation method [{'gridfit'} | 'griddata' |'inpaint_nans']
%   method_args - cell array with optional arguments to respective estimator function
% Output:
%   Iout - image with estimated background removed
%   Ibg - estimated backgound
%
% The background is estimated by using gridfit, griddata,
% inpaint_nans.
% 
% SEE also: GRIDFIT, GRIDDATA, INPAINT_NANS


%   Copyright � 2007 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if nargin < 3 || isempty(method)
  method = 'gridfit';
end
Iout = Iin;
switch method
 case 'gridfit'
  
  [x1,y1] = meshgrid(reg4bg(1):reg4bg(2),reg4bg(3):reg4bg(4));
  Ibg = Iin(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2));
  b = [Ibg(1,:),Ibg(end,:),Ibg(:,1)',Ibg(:,end)'];
  X = [x1(1,:),x1(end,:),x1(:,1)',x1(:,end)'];
  Y = [y1(1,:),y1(end,:),y1(:,1)',y1(:,end)'];
  
  if nargin < 4 || isempty(method_args)
    Ibg = gridfit(X,Y,b,x1(1,:),y1(:,1));
  else
    Ibg = gridfit(X,Y,b,x1(1,:),y1(:,1),method_args{:});
  end
  Iout = Iin;
  Iout(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2)) = Iout(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2)) - Ibg;
 case 'griddata'
  
  [x1,y1] = meshgrid(reg4bg(1):reg4bg(2),reg4bg(3):reg4bg(4));
  Ibg = Iin(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2));
  b = [Ibg(1,:),Ibg(end,:),Ibg(:,1)',Ibg(:,end)',Ibg(3,:),Ibg(end-2,:),Ibg(:,3)',Ibg(:,end-3)'];
  X = [x1(1,:),  x1(end,:), x1(:,1)', x1(:,end)', x1(3,:), x1(end-2,:), x1(:,3)', x1(:,end-2)'];
  Y = [y1(1,:),  y1(end,:), y1(:,1)', y1(:,end)', y1(3,:), y1(end-2,:), y1(:,3)', y1(:,end-2)'];
  
  if nargin < 4 || isempty(method_args)
    Ibg = griddata(X,Y,b,x1,y1,'cubic');
  else
    Ibg = griddata(X,Y,b,x1,y1,method_args);
  end
  Iout = Iin;
  Iout(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2)) = Iout(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2)) - Ibg;
  
 case 'inpaint_nans'
  
  Iout = Iin;
  Iout(reg4bg(3):reg4bg(4),reg4bg(1):reg4bg(2)) = nan;
  
  if nargin < 4 || isempty(method_args)
    Ibg = inpaint_nans(Iout);
  else
    Ibg = inpaint_nans(Iout,method_args);
  end
  Iout = Iin - Ibg;
 otherwise
  disp(['img_reg_bg_red: Unknown method: ',method,' selected'])
end
