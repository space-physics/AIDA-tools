function [Vem,stns] = tomo_start_guess1(stns,alt,width,X3D,Y3D,Z3D,infunction)
% TOMO_START_GUESS1 - One Grroooovy start guess for auroral
% tomography! STNS is an array of station structures, and should
% contain images and observation information such as from
% TOMO_INP_IMAGES; and camera and reconstruction volume information
% such as from CAMERA_SET_UP. X3D,Y3D and Z3D are the 3D grid of
% the reconstruction. Implicit requirement/assumption that Z3D is
% 'flat', that is Z3D(:,:,i) are all equal.
%   
% Calling:
% [Vem,stns] = tomo_start_guess1(stns,alt,width,X3D,Y3D,Z3D,infunction)
%
% See also tomo_skeleton, tomo_step, tomo_inp_images, adjust_level

%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


disp('You''re calling tomo_start_guess1 from:')
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

if isstruct(stns(1).optpar)
  optmod = stns(1).optpar.mod;
else
  optmod = stns(1).optpar(9);
end

if isfield(stns(1).obs,'trmtr')
  [xx1,yy1,zz1] = inv_project_img(stns(1).img, ...
                                  stns(1).r, ...
                                  optmod, ...
                                  stns(1).optpar, ...
                                  [0 0 1], ...
                                  alt, ...
                                  stns(1).obs.trmtr);
else
  
  [xx1,yy1,zz1] = inv_project_img(stns(1).img, ...
                                  stns(1).r, ...
                                  optmod, ...
                                  stns(1).optpar, ...
                                  [0 0 1], ...
                                  alt);
end
  
[qwe,alt_indx] = min(abs(alt-Z3D(1,1,:)));

try
  I2D1 = exp(gridfit(xx1,yy1,log(max(0.1,stns(1).img)),squeeze(X3D(1,:,alt_indx)),squeeze(Y3D(:,1,alt_indx)),'smoothness',smoothness));
  I2D1 = min(max(stns(1).img(:)),I2D1);
catch
  I2D1 = griddata(xx1,yy1,stns(1).img,squeeze(X3D(:,:,alt_indx)),squeeze(Y3D(:,:,alt_indx)));
  I2D1 = min(max(stns(1).img(:)),I2D1);
end
%i = find(~isfinite(I2D1(:)));
I2D1(~isfinite(I2D1(:))) = 0;
I2D = I2D1/max(I2D1(:));
Vem = 0*Z3D;
switch func2str(fcn)
 case 'chapman'
  
  for i1 = 1:size(Z3D,1),
    
    for j2 = 1:size(Z3D,2),
      
      Vem(i1,j2,:) = chapman(I2D(i1,j2),alt,width,squeeze(Z3D(i1,j2,:)));
      
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
      
      Vem(i1,j2,:) = I2D(i1,j2)*feval(fcn,squeeze(Z3D(i1,j2,:)));
      
    end
    
  end
  
end % switch func2str(fcn)



% done
[stns,Vem] = adjust_level(stns,Vem,1);
