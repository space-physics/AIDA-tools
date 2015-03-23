function [Keos,time_V,u,v] = ASK_fanograms(Indices2do,Cams,shifts,e_fan,width,OPS)
% ASK_FANOGRAMS - Produce keograms of a fan-beam-cut from an ASK image sequence
%
% CALLING:
%   OPS           = ASK_fanograms
%   [Keos,time_V] = ASK_fanograms(sIndices2do,Cams,shifts,e_fan,width,OPS)
% INPUTS:
%   indices2show - either array of image sequence numbers to
%                  display, or a triplett [first, step, last] or
%                  [first, last, step] with index to the first
%                  image to load the step to take to the next and
%                  the latest frame number to show. This means that
%                  one cannot display sequences of three arbitrary
%                  images - choose either 4 arbitrary and scrap the
%                  last.
%   Cams         - and array with the ASK camera numbers to read
%                  [1 x nC] where nC [1, 2, 3], if scalar only the
%                  images from the corresponding camera is processed.
%   shifts       - shift between concurrent images in the ASK camera
%                  sequences.
%   e_fan        - unit vectors for the lines-of-sight of the
%                  fan-beam to cut. [n x 3]
%   width        - width of the band that is used for creating the
%                  keogram,  
% 
%   OPS      - options struct, with the default options returned
%              when ASK_image_sequence is called without
%              arguments. Fields: 
%              filtertype = Cell array with strings for filter
%                functions to use selection from: 'none' 'sigma'
%                'wiener2' 'median' 'medfilt2' and 'susan'. See the
%                documentation for wiener2 (sigma, wiener2),
%                medfilt2 (median, medfilt2) gen_susan (susan) for
%                further arguments and workings. 
%              filterArgs = Cell array with cell-arrays of further
%                arguments except the image to pass to the
%                filterfunctions. Example
%                OPS.filtertype = {'sigma','medfilt2'}
%                OPS.filterArgs = {{[3,3]},{[3,3],'symmetric'}}
%                For filtering the image thusly:
%                Iout = medfilt2(wiener2(Iin,[3,3]),[3,3],'symmetric');
% 
% WARNING: If data is not calibrated this routine will crash!
% First of all the ASK meta-data has to be read in with read_vs!
% If the data is 512x512 pixels, the images will first be binned to
% 256x256 pixels
%

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs


% Default options:
dOPS.loud = 0;
dOPS.filtertype = {'none'};
dOPS.filterArgs = {};
% If no input arguments return the default options:
if nargin == 0
  Keos = dOPS;
  return
end
% If there is an options struct in the inputs, merge that ontop of
% the default ones.
if nargin > 5
  dOPS = merge_structs(dOPS,OPS);
end

width = round(width);

% Determine the image size of the current images;
imsiz = [vs.dimy(vs.vsel),vs.dimx(vs.vsel)];

% Preallocate the sizes for the output:
for cam = Cams,
  Keos{cam} = zeros(length(e_fan),length(Indices2do));
end

if dOPS.loud
  wbh = waitbar(0,'Making keograms');
end
for cam = Cams,
  
  i1 = 1; % was l???
  ASK_v_select(cam,'quiet'); % Select the current camera
  calib = ASK_get_ask_cal(vs.vmjs(vs.vsel),cam); % Get the calibration factors
  % Calculate the image coordinates of the fan line-of-sights
  [u{cam},v{cam}] = project_point([0,0,0],[vs.vcnv(vs.vsel,:),11],e_fan',eye(3),imsiz);
  % 2-D unit vector of fan's image coordinates
  E_pix  = [u{cam}(125)-u{cam}(124);v{cam}(125)-v{cam}(124)];
  % Rotate it 90 degrees to get a perpendicular vector
  E_perp = [0 1;-1,0]*E_pix;
  % Build a 2-D grid for the fan with the requested width:
  U = repmat(u{cam}',1,width) + repmat(linspace(-width/2,width/2,width),length(e_fan),1)*E_perp(1);
  V = repmat(v{cam}',1,width) + repmat(linspace(-width/2,width/2,width),length(e_fan),1)*E_perp(2);
  U = inpaint_nans(U);
  V = inpaint_nans(V);
  %keyboard
  for num = Indices2do,
    
    im{cam} = ASK_read_v(num+shifts(cam),[],[],[],dOPS); % Read the current ASK image
    time_V(i1,:) = ASK_indx2datevec(num+shifts(cam));
    % Extract and average the intensities in the fan
    Keos{cam}(:,i1) = mean(interp2(im{cam},U,V,'linear',0),2)*calib/vs.vres(vs.vsel);
    i1 = i1+1;
    if dOPS.loud
      waitbar(1/3*(cam-1)+i1/length(Indices2do)/3,wbh);
      if dOPS.loud > 1
        clf
        subplot(2,1,1)
        imagesc(im{cam})
        hold on
        plot(U,V)
        plot(U(180,:),V(180,:),'r+')
        plot(U(140,:),V(140,:),'b+')
        plot(U(220,:),V(220,:),'g+')
        subplot(2,1,2)
        plot(Keos{cam}(:,i1-1))
        hold on
        plot(mean(interp2(im{cam},U,V+10,'linear',0),2)*calib/vs.vres(vs.vsel),'g')
        plot(mean(interp2(im{cam},U,V+20,'linear',0),2)*calib/vs.vres(vs.vsel),'r')
        title(sprintf('Cam %d i1 %d',cam,i1))
        drawnow
        %keyboard
        pause(0.5)
      end
    end
    
  end
  
end

if dOPS.loud
  close(wbh)
end
