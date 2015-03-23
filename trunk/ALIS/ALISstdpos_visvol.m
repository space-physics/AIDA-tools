function hndl = ALISstdpos_visvol(stnNRs,AZstn,ZEstn,ALTstn,FOVstn,OPS)
% ALISSTDPOS_VISVOL - Display ALIS f-o-v ontop of topographic map 
%   ALISSTDPOS_VISVOL shows the fields-of-view of the ALIS stations
%   ontop of a topographic map (Either in longitude-latitude or
%   horizontal projection (at Kiruna))
%
% Calling:
%   hndl = ALISstdpos_visvol(stnNRs,AZstn,ZEstn,ALTstn,FOVstn,OPS)
% Input:
%   stnNRs - Station number of the ALIS stations to plot [1-7,10,11]
%            [nS x 1] or [1 x nS]
%   AZstn  - Azimuth angles same sized as stnNRs (degrees)
%   ZEstn  - Zenith angles same sized as stnNRs (degrees)
%   ALTstn - Altitudes  same sized as stnNRs (km)
%   FOVstn - Field-of-view angle same sized as stnNRs (degrees)
%   OPS    - Options struct as returned from AIDA_VISIBLEVOL
% Output:
%   hndl - handles to the lines of the fields-of-view
% 
% See also: AIDA_VISIBLEVOL


%   Copyright © 20110505 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


% [stnXYZ,stnLongLat,trmtr] = AIDApositionize([1:11],1);
[stnXYZ,stnLongLat] = AIDApositionize(1:11,1);

dOPS = aida_visiblevol;
dOPS.linewidth = 2;
dOPS.axlim = [];
dOPS.LL = 0;
dOPS.clrs = {'r','g','c','m',[0.2, 0.2, 0.2],'y'};
if nargin == 0
  hndl = dOPS;
  return
end
if nargin > 5
  dOPS = merge_structs(dOPS,OPS);
end

hold on

if isfield(dOPS,'LL') & dOPS.LL == 1
  % In Latitude and Longitude...
  hndl = aida_visiblevol(stnLongLat(stnNRs,[2,1]),AZstn, ZEstn,ALTstn,FOVstn,0,dOPS);
  PH = nscand_map('l',dOPS.axlim);
  xlabel('East','fontsize',15)
  ylabel('North','fontsize',15)
else
  % In cartesian coordinates...
  hndl = aida_visiblevol(stnXYZ(stnNRs,:),AZstn, ZEstn,ALTstn,FOVstn,0,dOPS);
  PH = nscand_map('c',dOPS.axlim);
  xlabel('East of Kiruna (km)','fontsize',15)
  ylabel('North of Kiruna (km)','fontsize',15)
end  
set(gca,'fontsize',15)
