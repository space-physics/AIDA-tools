function star_list = fix_ra_decl(star_list)
% FIX_RA_DECL - Extract rect ascension and declination from star
% catalogs. 
% 
% Private function, not much use for user, should be called in next
% version of SKYMAP.


%   Copyright � 19970907 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if isfield(star_list,'DEd')
  
  DE = [[star_list(:).DEd]'  [star_list(:).DEm]'];
  RA = [[star_list(:).RAh]'  [star_list(:).RAm]' [star_list(:).RAs]'];
  
  de_sign = [star_list(:).DE_];
  de_sign = 2*(.5-[[de_sign]=='-']);
  
  % decl = de_sign'.*([DE(:,1)]+[DE(:,2)]/60);
  decl = de_sign'.*(DE(:,1) + DE(:,2)/60);
  if isfield(star_list,'DEs')
    decl = decl+[star_list(:).DEs]'/3600;
  end
  ra = RA(:,1) + RA(:,2)/60 + RA(:,3)/3600;
  for i = 1:length(decl),
    
    star_list(i).decl = decl(i);
    star_list(i).ra = ra(i);
    
  end
  
  star_list = rmfield(star_list,{'RAh','RAm','RAs','DE_','DEd','DEm'});
  
  if isfield(star_list,'DEs')
    star_list = rmfield(star_list,{'DEs'});
  end
  
elseif isfield(star_list,'DEd1900')
  
  DE = cell2mat([[{star_list(:).DEd1900}]'  [{star_list(:).DEm1900}]']);
  RA = cell2mat([[{star_list(:).RAh1900}]'  [{star_list(:).RAm1900}]' [{star_list(:).RAs1900}]']);
  
  de_sign = cell2mat([{star_list(:).DE_1900}]);
  de_sign = 2*(.5-[[de_sign(:)]=='-']);
  
  decl = de_sign'.*([DE(:,1)]+[DE(:,2)]/60);
  if isfield(star_list,'DEs1900')
    decl = decl+[star_list(:).DEs1900]'/3600;
  end
  ra = RA(:,1) + RA(:,2)/60 + RA(:,3)/3600;
  for i = 1:length(decl),
    
    star_list(i).decl = decl(i);
    star_list(i).ra = ra(i);
    
  end
  
  star_list = rmfield(star_list,{'RAh1900','RAm1900','RAs1900','DE_1900','DEd1900','DEm1900'});
  
  if isfield(star_list,'DEs1900')
    star_list = rmfield(star_list,{'DEs1900'});
  end
  
end
