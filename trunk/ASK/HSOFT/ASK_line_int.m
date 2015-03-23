function [line_I,timeOut,mjsT0] = ASK_line_int(Nstart,Num4itter,x0,y0,r,step)
% ASK_LINE_INT - make intensity line plots from an image sequence.
% Averages the intensity in a circular mask applied over the image.
% 
% Calling:
%  line_I = ASK_line_int(Nstart,Num4itter,x0,y0,r,step)
% Inputs:
%  Nstart - First frame number
%  Num4itter - Number of frames to consider (ignoring the effect of
%              the step) 
%  x0,y0 - The centre of the circular mask in pixel coordinates.
%  r     - The radius of the mask, in pixels.
%  step  - step size, instead of plotting every image value
% Outputs:
%  line_I  - The total intensity within the circular mask, an array with one
%            value for each time.
%  timeOut - Array of times, in seconds since mjs. This is the time axis for
%            the resulting line.
%  mjsT0   - mjs of first data point.
%       


% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

% global hities % Unused
global vs

nx = vs.dimx(vs.vsel);
ny = vs.dimy(vs.vsel);

if nargin < 3 | isempty(x0)
  x0 = nx/2;
end
if nargin < 4 | isempty(y0)
  y0 = ny/2;
end
if nargin < 5 | isempty(r)
  r = ny/40;
end

%
% added to handle the steps
%
nstep = vs.vnstep(vs.vsel);
num_ = Num4itter * nstep;

% Make sure that the last image # is less than or equal to the
% number of images in the sequence (mega-block?)
if ( Nstart + num_) < vs.vnl(vs.vsel)
  nla = Nstart + num_-1;
else
  nla = vs.vnl(vs.vsel);
end
num_new = (nla-Nstart)/nstep;

if nargin < 6 | isempty(step) 
  step = 1;
end

line_I = zeros(1,( num_new + 1 )/step);
timeOut = zeros(1,( num_new + 1 )/step);
mjsT0  = ASK_time_v(Nstart, 1);

mask = double(ASK_roundmask( nx,ny,x0,y0,r));
nmask = sum(mask(:));

count = 1;
%TBR: oldpercent = 0;

for i1 = Nstart:step*nstep:nla,
  
  timeOut(count)  =  ASK_time_v(i1)-ASK_time_v(Nstart)+vs.vres(vs.vsel)*step/2;
  for j2 = i1:nstep:i1+step*nstep-1,
    
    img_out = ASK_read_v(j2);% noImCal, RGBout, nocnv); % read_v,j,im
    line_I(count) = line_I(count) + sum(img_out(logical(mask(:))))/nmask;
    
  end
  line_I(count) = line_I(count)/step; %remove the division by step, and you get the added intensity instead, added over time (step = 10 would then mean add 10 images together to one data point)
  count = count+1;
  
end
line_I = line_I(1:count-1);
timeOut = timeOut(1:count-1);
