function [star_list] = read_bsc(catalog,star_pos)
% READ_BSC reads Bright Star Catalog, makes STAR_LIST of information
% about all the stars in the YBS star catalog.
% 
% Calling:
%  [star_list] = read_ybs(fp,star_pos)
% 
% The star_list structure has the followin fields:
% struct('Name',name,...          %% string
%         'Type',type,...         %% string
%         'Specral',spectral,...  %% string
%         'Ra',Ra,...             %% string
%         'Decl',decl,...         %% string
%         'Magn',magn,...         %% string
%         'Azimuth',0,...         %% value
%         'Zenith',0,...          %% value
%         'App_Zenith',0);        %% value
%       

%   Copyright � 1999 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global stardir

%i = 1;

fname = fullfile(stardir,'stars','named.stars');
fp = fopen(fname,'r');
cl = 1;
while 1
  line = fgetl(fp); 
  if ~ischar(line),
    break,
  end
  cl = cl+1;
  this_name = deblank(line(1:end-5));
  Names(cl,1:length(this_name)) = this_name;
  Name_n_number(cl) = str2num(line(end-4:end));
end
fclose(fp);

for i1 = length(catalog):-1:1,
  
  line = catalog(i1,:);
  name = fliplr(deblank(fliplr(deblank(line(5:14)))));
  Bright_Star_Nr = str2num(line(1:4));
  HDNr = str2num(line(26:31));
  nrindx = find(Name_n_number==Bright_Star_Nr);
  if ~isempty(nrindx)
    name = deblank(Names(nrindx,:));
  end
  type = 'Star';
  multiple = ~isempty(deblank(line(44)));
  if multiple
    type = 'Multiple star';
    if line(44) == 'A' || (~isempty(str2num(line(50:51))) &&  str2num(line(50:51)) == 2)
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
  Ra = [line(76:77),':',line(78:79),':',line(80:83)];
  decl = [num2str(str2num(line(84:86))),':',line(87:88),':',line(89:90)];
  magn = line(103:107);
  %ok = 0;
  star_list(i1) = struct('Name',deblank(name),...
			'Type',type,...
			'Ra',Ra,...
			'Decl',decl,...
			'Magn',magn,...
			'Azimuth',0,...
			'Zenith',0,...
			'App_Zenith',0,...
			'H_D_number',HDNr,...
			'Bright_Star_Nr',Bright_Star_Nr);
  
end

try
  
  load(fullfile(stardir,'stars','BSN_RGB.dat'))
  for i1 = 1:length(star_list),
    
    if any(BSN_RGB(:,1)==star_list(i1).Bright_Star_Nr)
      
      star_list(i1).spectra = 1;
      star_list(i1).rgb = BSN_RGB(BSN_RGB(:,1)==star_list(i1).Bright_Star_Nr,2:4);
      
    else
    
      star_list(i1).spectra = 0;
      star_list(i1).rgb = [];
    end
    
  end
catch
  
  load(fullfile(stardir,'stars','BSN_w_spectra.dat'))
  
  for i1 = 1:length(star_list),
    
    if any(BSN_w_spectra==star_list(i1).Bright_Star_Nr)
      
      star_list(i1).spectra = 1;
      star_list(i1).rgb = sk_make_rgb(star_list(i1).Bright_Star_Nr);
      
    else
    
      star_list(i1).spectra = 0;
      star_list(i1).rgb = [];
    end
    
  end
end

for i1 = 1:length(star_pos),
  
  star_list(star_pos(i1,3)).Azimuth = star_pos(i1,1)*180/pi;
  star_list(star_pos(i1,3)).Zenith = star_pos(i1,2)*180/pi;
  star_list(star_pos(i1,3)).App_Zenith = star_pos(i1,end)*180/pi;
  
end
