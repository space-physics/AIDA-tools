function [possiblestars,star_list] = read_BSC(pos0,date,time0)
% READ_BSC loads stars from the Bright Star Catalogue, (BSC Star
% Catalog.

% latitude [deg]) at time TIME0 (UTC)
% on the day DATE.
% 
% Calling:
% [possiblestars,star_list] = read_BSC(pos0,date,time0)
% 
% See also INFOV, PLOTTABLESTARS.


%   Copyright © 2012 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


global stardir

star_types = {'S','D','D','D','V','V','V','D-V','','','','',''};
indxNR  = [  1:4  ]; % index for Bright Star Number
indxRAd = [ 76:77 ]; % index for Right ascension degrees
indxRAm = [ 78:79 ]; % index for Right ascension minutes
indxRAs = [ 80:83 ]; % index for Right ascension seconds
indxDEd = [ 84:86 ]; % index for Declination degrees
indxDEm = [ 87:88 ]; % index for Declination minutes
indxDEs = [ 89:90 ]; % index for Declination seconds
indxMg  = [103:107]; % index for Visual magnitude
indxSp  = [128:147]; % index for Spectral type
indxTy  = [  44   ]; % index for Type
indxNm  = [ 5:14  ];   % index for Name

fname = fullfile(stardir,'stars','catalog.dat');
FID = fopen(fname,'r');

catalog = fread(FID,[197 9096],'uint8=>char')';

fclose(FID);

SAO_Star_Nr = str2num(catalog(:,indxNR));
raD         = str2num(catalog(:,indxRAd));
raM         = str2num(catalog(:,indxRAm));
raS         = str2num(catalog(:,indxRAs));
declD       = str2num(catalog(:,indxDEd));
declM       = str2num(catalog(:,indxDEm));
declS       = str2num(catalog(:,indxDEs));
magn        = str2num(catalog(:,indxMg));
Spec        = catalog(:,indxTy);
typeID      = str2num(catalog(:,indxTy));
name        = catalog(:,indxNm);

long = pos0(1);
lat = pos0(2);


ra   =   raD +   raM/60 +   raS/3600;
decl = declD + declM/60 + declS/3600;

[az,ze,apze] = starpos2(ra,decl,date,time0,lat,long);
[i1] = find(ze<pi/2);

possiblestars(:,1:7) = [az(i1) ze(i1) i1 magn(i1) zeros(size(i1)) SAO_Star_Nr(i1) apze(i1)];

  
for i1 = length(catalog):-1:1,
  
  line = catalog(i1,:);
  type = 'Star';
  multiple = ~isempty(deblank(line(44)));
  if multiple
    type = 'Multiple star';
    if line(44) == 'A' | str2num(line(50:51)) == 2
      type ='Double star';
    else
      if ~isempty(deblank(line(50:51)))
	    type = [type,' (',deblank(line(50:51)),')'];
      end
    end
  end
  variable = ~isempty(deblank(line(52:60)));
  if variable
    type = ['Variable ',type];
  end
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
