function ASK_make_askdark(filename,flat)
% ASK_MAKE_ASKDARK - Script that creates darks or flats.
% Default is darks, but set keyword flat to do flats.
% filename is for example 20061020164150d1
% The resulting dark or flat is saved in $VIDEODIR/setup/
%
% Calling:
%   ASK_make_askdark(filename,flat)
% Input:
%   filename - filename of dark-mega-block setup without .txt extension
%   flat     - flag to set to one for making a "flat" image

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

global vs

ASK_read_vs([],[filename,'.txt'],0);
%For darks, 100 images

a = 1;
data = zeros(vs.dimx(vs.vsel),vs.dimy(vs.vsel),vs.vnl(vs.vsel));
% discarding the data from the first five seconds:
% changed by Sam - 04/11/10 
% changed to discard only first four seconds as discarding five
% causes problems when creating flats (image 141 does not exist in
% mean set of images)
for j1 = (vs.vnf(vs.vsel) + 4/vs.vres(vs.vsel)):vs.vnstep(vs.vsel):vs.vnl(vs.vsel),
  
  intensity = ASK_read_v( j1, 'raw');
  data(:,:,a) = intensity;
  a = a + 1;
  
end

discard = fix(max([0.05*a,2.0]));
filtered_mean = zeros(vs.dimy(vs.vsel),vs.dimx(vs.vsel));

% Take mean after excluding top and bottom 5% of intensities for each pixel.
for i1 = 1:vs.dimx(vs.vsel),
  for j2 = 1:vs.dimy(vs.vsel),
    sorted = sort(squeeze(data(i1,j2,:)));
    filtered_mean(i1,j2) = mean( sorted(discard:(end-discard+1)) );
  end
end
if nargin > 1 & flat
  ext = '.flat';
else
  ext='.dark';
end
disp(['Now writing file: ',fullfile(vs.videodir,'setup',[filename,ext]),' for background removal.'])
disp(['Consider renaming it to: ',fullfile(vs.videodir,'setup',[filename,lower(ext)])])

if exist(fullfile(vs.videodir,'setup',[filename,ext]),'file') == 2
  [status, message] = backup1000filesversions(fullfile(vs.videodir,'setup',[filename,ext]));
end

fID = fopen(fullfile(vs.videodir,'setup',[filename,ext]),'w');
fwrite(fID,filtered_mean,'float');
fclose(fID);
