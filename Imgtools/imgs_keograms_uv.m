function [Keo,exptimes,Tstrs,filters] = imgs_keograms_uv(files,u,v,optpar,PO)
% imgs_keogram_uv - make "keogram" along image coordinates [u,v].
%   FILES should be a char-arry with filenames (readable) (full or
%   relative path), PO should be a struct with PRE_PROC_OPS, RS
%   should be the [1x3] vector of the observation position.
% 
% Calling:
% [Keo,exptimes,Tstrs,filters] = imgs_keograms_uv(files,u,v,PO)
% 
%   See also: INIMG, STARCAL, TYPICAL_PRE_PROC_OPS


%   Copyright � 20130618 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

ff_everystep = 0;

if nargin>=4 && length(optpar)>8 && 0
  if isstruct(optpar)
    ff = ffs_correction2(PO.outimgsize.*[1 1],optpar,optpar.mod);
  else
    ff = ffs_correction2(PO.outimgsize.*[1 1],optpar,optpar(9));
  end
  if isempty(ff)
    ff_everystep = 1;
  else
    imagesc(1./ff),title(files(1,:)),colorbar,drawnow
  end
else
  ff = 1;
end

[data1] = inimg(files(1,:),PO);
bxy = size(data1);

for i1 = size(files,1):-1:1,
  
  [data1,head1,o] = inimg(files(i1,:),PO);
  exptimes(i1) =  o.exptime;
  if exptimes(i1)<100
    exptimes(i1) = 1000*exptimes(i1);
  end
  if isempty(o.time)
    Tstrs(i1,:) = time_from_header(head1);
  else
    Tstrs(i1,:) = o.time;
  end
  filters(i1) = o.filter;
  
  if ff_everystep
    if isstruct(optpar)
      ff = ffs_correction2(size(data1),optpar,optpar.mod);
    else
      ff = ffs_correction2(size(data1),optpar,optpar(9));
    end
  end
  data1 = 1000*data1./ff/exptimes(i1);
  Keo(i1,:) = interp2(data1,u,v);
  
end