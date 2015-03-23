function stns = tomo_inp_images(file_list,stns,img_ops)
% TOMO_INP_IMAGES - Preprocessing of images for tomography plus
% setting up stations. FILE_LIST is all images to use for
% tomographic inversion, IMG_OPS are an optional struct with
% preprocessing options, defaults are 3x3 median filtering,
% quadrant correction and image resizing to 256x256 pixels.
%   
% Calling
% stns = tomo_inp_images(file_list,stns,img_ops)
% Output:
% STNS - station-struct array, incomplete if not a complete is
%        given in the input.


%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


ALIS_FITS = 1; % Fits header contain ALIS specific info.

PREPROC_OPS = typical_pre_proc_ops;
PREPROC_OPS.quadfix = 2;          % number of overscan strips
PREPROC_OPS.quadfixsize = 0;      % size of overscanstrip 0 =>
                                  % cunning guess
PREPROC_OPS.replaceborder = 1;    % replace image border or not
PREPROC_OPS.medianfilter = 3;     % size of medianfilter
PREPROC_OPS.outimgsize = [256 256];% resize the image to 256x256 - postbinning
PREPROC_OPS.findoptpar = 1;

% Merge the user IMG_OPS with the default PREPROC_OPS
if nargin==3 && ~isempty(img_ops)
  PREPROC_OPS = img_ops;
end
%if nargin == 3 & 0
%  
%  P_OPS(1:length(img_ops)) = PREPROC_OPS;
%  for j = 1:length(img_ops),
%    
%    img_f = fieldnames(img_ops(j))
%    for i = 1:length(img_f),
%      P_OPS(i) = setfield(PREPROC_OPS,img_f{i},getfield(img_ops(j),img_f{i}));
%    end
%  end
%  PREPROC_OPS = P_OPS;
%end

if iscell(file_list)
  
  nrimages = length(file_list);
  
else
  
  nrimages = size(file_list,1);
  
end

sp = fix_subplots_tomo(nrimages);

for i = 1:nrimages,
  
  PO = PREPROC_OPS(min(i,length(PREPROC_OPS)));
  [stns(i).img,stns(i).head,stns(i).obs] = inimg(deblank(file_list(i,:)),PO);
  subplot(sp(1),sp(2),i)
  imagesc(stns(i).img),axis xy
  drawnow
  
  if ~isempty(stns(i).head) % Todo: plocka bort?
    
    try
      stns(i).optpar = PREPROC_OPS(min(i,length(PREPROC_OPS))).optpar;
      if isempty(stns(i).optpar)
        stns(i).optpar = find_optpar2(stns(i).obs);
      end
    catch
      if ALIS_FITS
        
        stns(i).optpar = find_optpar2(stns(i).obs);
        
      else
        %Other users must insert there own methods for finding the
        %necessary information about the camera rotation and optical
        %parameters 
        error(['I dont know what to do now. No information about camera' ...
               ' parameters...'])
        
      end
    end
    optpar = stns(i).optpar;
    imgsize = size(stns(i).img);
    % Goer osnygg skalning haer. Mainly to reduce memmory usage.
    if isstruct(optpar)
      stns(i).img = stns(i).img./ffs_correction2(imgsize,optpar,optpar.mod);
    else
      stns(i).img = stns(i).img./ffs_correction2(imgsize,optpar,optpar(9));
    end
    % TODO: ids inte fixa med filtren nu FIXA!!!!!!
    subplot(sp(1),sp(2),i)
    imagesc(stns(i).img),axis xy
    title(['Station ',num2str(stns(i).obs.station)])
    drawnow
    
    try
      if isstruct(optpar)
        optmod = optpar.mod;
      else
        optmod = optpar(9);
      end
      stns(i).img = (stns(i).img)./atm_attenuation(imgsize,optpar,optmod,alis_filter_fix(stns(i).obs.filter),1);
    catch
      warning(['Could for some reason not make corrections for ' ...
               'atmospheric attenuation'])
    end
  end
  subplot(sp(1),sp(2),i)
  imagesc(stns(i).img),axis xy
  title(['Station ',num2str(stns(i).obs.station)])
  drawnow
end
