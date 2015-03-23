function [possiblestars,star_list] = read_SAO(pos0,date,time0)
% READ_SAO loads stars from the SAO Star Catalogue, (SAO Star
% Catalog J2000) subset of stars with declination above 50 degrees
% and pick the stars that are above the horizon at POS0 (longitude,
% latitude [deg]) at time TIME0 (UTC)
% on the day DATE.
% 
% Calling:
% [possiblestars,star_list] = read_SAO(pos0,date,time0)
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

% These below seems to be unused at the moment:
%indxRAd = [151:152]; % index for Right ascension degrees
%indxRAm = [153:154]; % index for Right ascension minutes
%indxRAs = [155:160]; % index for Right ascension seconds
%indxDEd = [168:170]; % index for Declination degrees
%indxDEm = [171:172]; % index for Declination minutes
%indxDEs = [173:177]; % index for Declination seconds
% SAO contains R.Asc and Decl in decimal form too...

fname = fullfile(stardir,'stars','SAO_gt50dec.dat');
FID = fopen(fname,'r');

catalog = fread(FID,[205 36088],'uint8=>char')';

fclose(FID);

SAO_Star_Nr = str2num(catalog(:,indxNR));
ra          = str2num(catalog(:,indxRA))*12/pi;
decl        = str2num(catalog(:,indxDE))*180/pi;

% $$$ ra = ( str2num(catalog(:,76:77)) + ...
% $$$        str2num(catalog(:,78:79))/60 + ...
% $$$        str2num(catalog(:,80:83))/3600 )*180/pi;
% $$$ 
% $$$ decl = ( str2num(catalog(:,84:86)) + ...
% $$$ 	 str2num(catalog(:,87:88))/60 + ...
% $$$ 	 str2num(catalog(:,89:90))/3600 )*180/pi;


magn        = str2num(catalog(:,indxMg));
Spec        = catalog(:,indxTy);
type        = star_types(str2num(catalog(:,indxTy))+1);
name        = catalog(:,indxNm);

long = pos0(1);
lat = pos0(2);

% disp([lat long])

[az,ze,apze] = starpos2(ra,decl,date,time0,lat,long);
[i1] = find(ze<pi/2);

possiblestars(:,1:7) = [az(i1) ze(i1) i1 magn(i1) zeros(size(i1)) SAO_Star_Nr(i1) apze(i1)];


for i1 = length(catalog):-1:1,
  
  star_list(i1) = struct('Name',name(i1,:),...
                         'Spectral_type',Spec(i1,:),...
                         'Type',type{i1},...
                         'Ra',ra(i1),...
                         'Decl',decl(i1),...
                         'Magn',magn(i1),...
                         'Azimuth',az(i1)*180/pi,...
                         'Zenith',ze(i1)*180/pi,...
                         'App_Zenith',apze(i1)*180/pi,...
                         'Bright_Star_Nr',SAO_Star_Nr(i1));
  
end
