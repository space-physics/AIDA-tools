function ASK_get_imcal()
% ASK_GET_IMCAL - routine filling the imcal common block with
% the dark image and flat image, for a video event.
% The dark and flat images are read in from the files.
% NOTE: The name is misleading! fmd_field is actually
% the normalised flat NOT the flat minus dark.
% This is because absolute intensity calibration would
% otherwise not work, if the brightness of the flat is
% not known, e.g. when of clouds.
%
% Calling:
%   ASK_get_imcal
% Input:
%   None.
% Output:
%   None
% Results stored in a global struct: imcal


% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

% global hities % Unused
global vs    % Holding camera meta data of the current event.
global imcal % FOR: d_field, fmd_field

nx = vs.dimx(vs.vsel);
ny = vs.dimy(vs.vsel);

imcal.d_field = zeros(ny,nx);
imcal.fmd_field = ones(ny,nx);

if ~strcmp(vs.vdrk{vs.vsel},'nodark')
  
  filename = fullfile(vs.videodir,'setup',vs.vdrk{vs.vsel});
  fID = fopen(filename,'r');
  imcal.d_field = fread(fID,[ny,nx],'float'); 
  fclose(fID);
  
end

if ~strcmp( vs.vflt(vs.vsel),'noflat')
  
  filename = fullfile(vs.videodir,'setup',strtrim(vs.vflt{vs.vsel}));
  fID = fopen(filename,'r');
  imcal.fmd_field = fread(fID,[nx,ny],'float'); 
  fclose(fID);
  
end

imcal.fmd_field = imcal.fmd_field/mean(imcal.fmd_field(:));%  -d_field
