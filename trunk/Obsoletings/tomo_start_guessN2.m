function [Vem,stns] = tomo_start_guessN2(stns,alt,width,X3D,Y3D,Z3D,infunction,OPS)
% TOMO_START_GUESSN2 - Fancy start guess for auroral tomography!
% STNS is an array of station structures, and should
% contain images and observation information such as from
% TOMO_INP_IMAGES; and camera and reconstruction volume information
% such as from CAMERA_SET_UP. X3D,Y3D and Z3D are the 3D grid of
% the reconstruction. Implicit requirement/assumption that Z3D is
% 'flat', that is Z3D(:,:,i) are all equal.
% 
% Calling:
% [Vem,stns] = tomo_start_guessN2(stns,alt,width,X3D,Y3D,Z3D,infunction,OPS)
%
% See also tomo_skeleton, tomo_step, tomo_inp_images, adjust_level

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

disp('You''re calling tomo_start_guessN2 from:')
dbstack
disp('I stronlgy suggest that you switch to use: tomo_err4sliceGACT')


fcn = '';
if nargin > 6
  
  fcn = infunction;
  if ischar(fcn)
    fcn = str2func(fcn);
  end
  
end
if ~isa(fcn,'function_handle')
  fcn = str2func('chapman');
end

smoothness = 0.03;
if nargin > 7 & isfield(OPS,'smoothness');
  
  smoothness = OPS.smoothness;
  
end

for iN = length(stns):-1:1,
  if isstruct(stns(iN).optpar)
    optmod{iN} = stns(iN).optpar.mod;
  else
    optmod{iN} = stns(iN).optpar(9);
  end
  
  [xx{iN},yy{iN},zz{iN}] = inv_project_img(stns(iN).img, ...
                                           stns(iN).obs.xyz, ...
                                           optmod{iN}, ...
                                           stns(iN).optpar, ...
                                           [0 0 1], ...
                                           alt, ...
                                           stns(iN).obs.trmtr);
end

[qwe,alt_indx] = min(abs(alt-Z3D(1,1,:)));

maxI = 0;
try
  for iN = length(stns):-1:1,
    I2D{iN} = exp(gridfit(xx{iN},yy{iN},log(stns(iN).img),squeeze(X3D(1,:,alt_indx)),squeeze(Y3D(:,1,alt_indx)),'smoothness',smoothness));
    I2D{iN} = min(max(stns(iN).img(:)),I2D{iN});
    maxI = max(maxI,max(stns(iN).img(:)));
  end
catch
  for iN = length(stns):-1:1,
    I2D{iN} = griddata(xx{iN},yy{iN},stns(iN).img,squeeze(X3D(:,:,alt_indx)),squeeze(Y3D(:,:,alt_indx)));
    I2D{iN} = min(max(stns(iN).img(:)),I2D{iN});
  end
end

for iN = 1:length(stns),
  %i_n = find(~isfinite(I2D{iN}(:)));
  I2D{iN}(~isfinite(I2D{iN}(:))) = 0;
end

I2d = I2D{1};
for iN = 2:length(stns),
  
  I2d = I2d+I2D{iN};
  
end

I2d = min(I2d,2*maxI);
Vem = zeros(size(Z3D));
switch func2str(fcn)
 case 'chapman'
  
  for i1 = 1:size(Z3D,1),
    
    for j2 = 1:size(Z3D,2),
      
      Vem(i1,j2,:) = chapman(I2d(i1,j2),alt,width,squeeze(Z3D(i1,j2,:)));
      
    end
    
  end
  
 case 'gauss_alt'
  
  for i1 = 1:size(Z3D,1),
    
    for j2 = 1:size(Z3D,2),
      
      Vem(i1,j2,:) = gauss_alt(I2D(i1,j2),alt,width,squeeze(Z3D(i1,j2,:)));
      
    end
    
  end
  
 otherwise
  
  for i1 = 1:size(Z3D,1),
    
    for j2 = 1:size(Z3D,2),
      
      Vem(i1,j2,:) = feval(fcn,I2D(i1,j2),alt,width,squeeze(Z3D(i1,j2,:)));
      
    end
    
  end
  
end % switch func2str(fcn)

% faerdigt
[stns,Vem] = adjust_level(stns,Vem,1);
