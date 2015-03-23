function [C,sigma2C] = pixel2pixel(files,m_size,PO)
% PIXEL2PIXEL - p-2-p variation in photo responce non uniformity 
% The p-2-p variation in PRNU is estimated as (ASCII-art _everyone_
% loves ASCII-art)
%          ___ 
%       1 \     
%   C = -  >   I_i./medfilt2(I_i,m_size)
%       N /___ 
%        i =1:N
%
% This works under the assumption that the intensity gradients in
% the images I_i is small and I_i on average is flat and smooth,
% Small-scale structures are supposed to be transient and that
% their contribution are averaged out.
%
% Calling:
% [C,sigma2C] = pixel2pixel(files,m_size,PO)
% Input:
%   FILES - string matrix with filenames (full or relative) to the
%           images. The number of files should preferably be rather
%           large (500++)
%   M_SIZE - size of the region to use in the median filtering, 
%            [5 5] seems good.
%   PO - Pre-processing-struct see TYPICAL_PRE_PROC_OPS
% Output:
%  C - pixel-to-pixel variation of photo-response non-uniformity,
%      same size as images.
%  sigma2C - standard deviation of C, same size.


%   Copyright © 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later



%load('/home/bjorn/matlab/AIDA_tools/Skymap/stars/catalog.bjg')
load(fullfile(fileparts(which('skymap')),'stars','catalog.bjg'))
Ybs = catalog;
is = find(Ybs(:,end-1)<5);

PO.badpixfix = 0;
PO.medianfilter = 0;
PO.BE = 1;
PO.remove_these_stars = [Ybs(is,1)+Ybs(is,2)/60+Ybs(is,3)/3600 Ybs(is,4)+Ybs(is,5)/60+Ybs(is,6)/3600];

%[d,h,o] = inimg(files(1,:),PO);
d = inimg(files(1,:),PO);

if isstruct(PO.optpar)
  ff = ffs_correction2(size(d),PO.optpar,PO.optpar.mod);
elseif length(PO.optpar) > 7
  ff = ffs_correction2(size(d),PO.optpar,PO.optpar(9));
else
  ff = ffs_correction2(size(d),PO.optpar,3);
end
ff = real(ff);

C = zeros(size(ff));

ni = C;
for i1 = 1:size(files,1),
  %[d,h,o] = inimg(files(i,:),PO);
  d = inimg(files(i1,:),PO);
  d = d./ff;
  md = medfilt2(d([ones(1,floor(m_size(1)/2)) ...
                   1:end ...
                   end*ones(1,floor(m_size(1)/2))],...
                  [ones(1,floor(m_size(2)/2)) ...
                   1:end ...
                   end*ones(1,floor(m_size(2)/2))]),...
                  m_size);
  md = md(ceil(m_size(1)/2):end-floor(m_size(1)/2),...
          ceil(m_size(2)/2):end-floor(m_size(2)/2));
  
  ifinite = isfinite(md(:));
  C(ifinite) = C(ifinite) + d(ifinite)./md(ifinite);
  ni(ifinite) = ni(ifinite)+1;
end
C = C./ni;

if ( nargout > 1 )
  
  sigma2C = zeros(size(d));
  for i1 = 1:size(files,1),
    
    %[d,h,o] = inimg(files(i,:),PO);
    d = inimg(files(i1,:),PO);
    d = d./ff;
    sigma2C = sigma2C + 1./( ni - 1 ) .* ( C - d./medfilt2(d,m_size) ).^2;
    
  end
  
end
