function [keo1,keo2,keo3,time_V] = ASK_keograms(fir,las,ste,width,x0,y0,angle,bkg,dist,OPS)
% ASK_KEOGRAMS - Produce keograms keograms from an ASK image sequence
%
% CALLING:
%   [keo1,keo2,keo3,time_V] = ASK_keograms(fir,las,ste,width,x0,y0,angle,bkg,dist)
% INPUTS:
%   fir      - first image number 
%   las      - last image number 
%   ste      - frame step 
%   shift    - shift of images with respect to each other ([0,0,0] if there is no shift), 
%   width    - width of the column that is used for creating the keogram, 
%   x0, y0   - central pixles of the keogram cut, 
%   angle    - angle of the cut, where 0 is a horizontal cut and 90
%              vertical. 
%   name     - the name of the resulting ps-file 
%
% Optional arguments:
%   bkg      - background to remove from [ASK1,ASK2,ASK3]
%   dist     - Puts distance on the y-axis in km (set up for ASK data)
%
% The nicest keograms are created from appr. 1000 frames.
% WARNING: If data is not calibrated this routine will crash!
% First of all the ASK meta-data has to be read in with read_vs!
% If the data is 512x512 pixels, the images will first be binned to
% 256x256 pixels
%

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs

dOPS = ASK_read_v;
dOPS.loud = 0;
if nargin == 0
  keo1 = dOPS;
  return
elseif nargin > 9 & ~isempty(OPS)
  dOPS = merge_structs(dOPS,OPS);
end

if nargin < 8 | isempty(bkg)
  bkg = [0,0,0];
end


nelem = (las - fir)/ste + 1;

time_V = zeros(nelem,6);
keo1 = zeros(256,nelem);
keo2 = keo1;
keo3 = keo1;

i1 = 1; % was l???

for num = fir:ste:las
  if dOPS.loud
    disp(num)
  end
  % Read the three current images
  ASK_v_select(1,'quiet'); % Set current camera to 1
  im1 = ASK_read_v(num,[],[],[],dOPS);   % Read the ASK#1 image
  time_V(i1,:) = ASK_indx2datevec(num);
  
  % If required do post-binning to 256 x 256
  if all([vs.dimx(vs.vsel) vs.dimy(vs.vsel)] == [512 512])
    im1 = ASK_binning(im1,[2,2]);
  end
  ASK_v_select( 2, 'quiet'); % Cycl.
  im2 = ASK_read_v(num,[],[],[],dOPS);     % Cycl.
  if all([vs.dimx(vs.vsel) vs.dimy(vs.vsel)] == [512 512])% Cycl...
    im2 = ASK_binning(im2,[2,2]);
  end
  ASK_v_select( 3, 'quiet'); % Cycl..
  im3 = ASK_read_v(num,[],[],[],dOPS);     % Cycl..
  if all([vs.dimx(vs.vsel) vs.dimy(vs.vsel)] == [512 512])% Cycl...
    im3 = ASK_binning(im3,[2,2]);
  end
  
  % Rotate images:
  im_1 = img_rot(im1,-(angle-90),x0,y0,'*spline',0);
  im_2 = img_rot(im2,-(angle-90),x0,y0,'*spline',0);
  im_3 = img_rot(im3,-(angle-90),x0,y0,'*spline',0);
  % Display current image
  if dOPS.loud
    imagesc(im_3),
    axis xy
    drawnow
  end
  % Extract intensity cut for building the keograms:
  lin1 = mean(im_1(:,127-width/2:127-width/2+width-1),2);
  lin2 = mean(im_2(:,127-width/2:127-width/2+width-1),2);
  lin3 = mean(im_3(:,127-width/2:127-width/2+width-1),2);
  % Stuff the line-intensities into the keograms:
  keo1(:,i1) = lin1 - bkg(1);
  keo2(:,i1) = lin2 - bkg(2);
  keo3(:,i1) = lin3 - bkg(3);
  
  i1 = i1+1;
  
end
