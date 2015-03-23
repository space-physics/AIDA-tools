function [Bout] = get_B_EISCAT(SiteNames)
% GET_B_EISCAT - get geomagnteic fields for the EISACT sites.
%   
% Calling:
%  B = get_B_EISCAT(SiteNames)
% Output:
%  B - Geomagnetic field at Troms�, Kiruna, Sodankyl�, Longyearbyen
%      

%   Copyright � 2011 Bjorn Gustavsson <bjorn.gustavsson@irf.se>, 
%   This is free software, licensed under GNU GPL version 2 or later

fp = fopen('B-fields-EISCAT-sites.dat','r');
EISCAT_sites = textscan(fp,'%s%s%s%s%s',1);
B_cell = textscan(fp,'%f%f%f%f%f%f%s\n',14);
B_type = B_cell{end};



for i1 = 4:-1:1,
  
  sitename = EISCAT_sites{i1};
  B(i1).sitename = sitename{1};
  for i2 = 1:length(B_type),
    
    B(i1).(B_type{i2})(B_cell{5}(i2)) = B_cell{i1}(i2);
    B(i1).alt(B_cell{5}(i2))  = B_cell{6}(i2);
    
  end
  B(i1).B = [B(i1).Beast',B(i1).Bnorth',B(i1).Bup'];
  FirstChar(i1) = B(i1).sitename(1);
  
end
fclose(fp);
B = rmfield(B,{'Beast','Bnorth','Bup'});

if nargin && ~isempty(SiteNames)
  for i1 = length(SiteNames):-1:1,
    
    iIn2Out = findstr(lower(SiteNames{i1}(1)),lower(FirstChar));
    if ~isempty(iIn2Out)
      Bout(i1) = B(iIn2Out);
    end
  end
else
  Bout = B;
end
    
