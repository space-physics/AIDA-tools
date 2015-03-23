function [possiblestars,star_list] = read_sao(pos0,date,time0)
% READ_SAO loads stars from the SAO Star Catalogue, (SAO Star
% Catalog J2000) subset of stars with declination above 50 degrees
% and pick the stars that are above the horizon at POS0 (longitude,
% latitude [deg]) at time TIME0 (UTC)
% on the day DATE.
% 
% Calling:
% [possiblestars,catalog] = loadstars2(pos0,date,time0)
% 
% See also INFOV, PLOTTABLESTARS.


%   Copyright © 2012 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


global stardir

star_types = {'S','D','D','D','V','V','V','D-V','','','','',''};
indxNR = [  1:6  ]; % index for SAO number
indxRA = [184:193]; % index for Right ascension
indxDE = [194:204]; % index for Declination
indxMg = [ 81:84 ]; % index for Visual magnitude
indxSp = [ 85:87 ]; % index for Spectral type
indxTy = [  95   ]; % index for Type
indxNm = [118:123]; % index for Name - really Henry Draper number

fname = fullfile(stardir,'stars','SAO_gt50dec.dat');
FID = fopen(fname,'r');

catalog = fread(FID,[205 36088],'uint8=>char')';

fclose(FID);

SAO_Star_Nr = str2num(catalog(:,indxNR));
ra          = str2num(catalog(:,indxRA));
decl        = str2num(catalog(:,indxDE));
magn        = str2num(catalog(:,indxMg));
Spec        = catalog(:,indxTy);
type        = star_types(strtnum(catalog(:,indxTy))+1);
name        = catalog(:,indxMg);

long = pos0(1);
lat = pos0(2);


[az,ze,apze] = starpos2(ra,decl,date,time0,lat,long);
[i1] = find(ze<pi/2);

possiblestars(:,1:7) = [az(i1) ze(i1) i1 magn(i1) zeros(size(i1)) SAO_Star_Nr(i1) apze(i1)];

  
for i1 = length(catalog):-1:1,
  
  star_list(i1) = struct('Name',name(i1,:),...
                         'Spectral type',Spec(i1,:),...
			'Type',type{i1},...
			'Ra',ra(i1),...
			'Decl',decl(i1),...
			'Magn',magn(i1),...
			'Azimuth',az(i1),...
			'Zenith',ze(i1),...
			'App_Zenith',apze(i1),...
			'Bright_Star_Nr',SAO_Star_Nr(i1));
  
end
