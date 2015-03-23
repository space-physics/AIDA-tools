function [star_list] = read_ybs(fp,star_pos)
% [star_list] = read_ybs(fp,star_pos)
% 
% READ_YBS builds STAR_LIST containing star information
% about all the stars in the YBS star catalog.
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


%   Copyright © 1999 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

i = 1;

if exist('ybs.mat.gz','file')
  
  unix('gunzip ybs.mat.gz');
  
end


while ( 1 )
  
  line = fgetl(fp);
  if ~ischar(line)
    break,
  end 
  [name,line] = strtok(line,',');
  [dummy,line] = strtok(line,',|');
  [t,line] = strtok(line,',|');
  if ( t == 'D' )
    type = 'Double star';
  elseif ( t == 'S' )
    type = 'Star';
  elseif ( t == 'M' )
    type = 'Multiple star';
  elseif ( t == 'V' )
    type = 'Variable star';
  else
    type = 'Star';
  end
  [spectral,line] = strtok(line,'|,');
  [Ra,line] = strtok(line,',');
  [decl,line] = strtok(line,',');
  [magn] = strtok(line,',');
  %ok = 0;
  star_list(i) = struct('Name',name,...
                        'Type',type,...
                        'Specral',spectral,...
                        'Ra',Ra,...
                        'Decl',decl,...
                        'Magn',magn,...
                        'Azimuth',0,...
                        'Zenith',0,...
                        'App_Zenith',0);
  i = i+1;
end
fclose(fp);

for i1 = 1:length(star_pos),
  
  star_list(star_pos(i1,3)).Azimuth = star_pos(i1,1)*180/pi;
  star_list(star_pos(i1,3)).Zenith = star_pos(i1,2)*180/pi;
  star_list(star_pos(i1,3)).App_Zenith = star_pos(i1,end)*180/pi;
  
end
