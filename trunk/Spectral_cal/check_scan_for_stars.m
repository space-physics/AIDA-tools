function [ok] = check_scan_for_stars(files,pos,optpar,IDENTSTARS,STARPARS,PO,OPS)
% CHECK_SCAN_FOR_STARS  Check the result of spc_scan_for_stars.
% See spc_scan_for_stars for information about the input.
%
% Calling:
%  [ok] = check_scan_for_stars(files,pos,optpar,IDENTSTARS,STARPARS,PO,OPS)
% 

%   Copyright © 20030901 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

global stardir % bx by

% default display option 
if nargin==3
  disp_ops = 'off';
end

stardir = fileparts(eval('which(''skymap'')'));
%%%%%%% du maaste testa read_all_catalogs
readme_file = [stardir,'/stars/README.spectra'];
catalog_file = [stardir,'/stars/stars.dat'];
get_these_fields = [1 4 7 8 9 10 11 12 14 16];
star_list = read_all_astro_catalogs(catalog_file,readme_file,get_these_fields);
star_list = star_list(2:end);
star_list = fix_ra_decl(star_list);

if nargin >= 7 &  ~isempty(OPS.Mag_limit)
  
  %i = find([star_list(:).Vmag] <= OPS.Mag_limit);
  %star_list = star_list(i);
  star_list = star_list([star_list(:).Vmag] <= OPS.Mag_limit);
  
end
ra = [star_list(:).ra]';
decl = [star_list(:).decl]';

% image preprocessing options
if nargin <= 5 | isempty(PO)
  PO = typical_pre_proc_ops;
  PO.outimgsize = 256;
  PO.LE = 1;
  PO.medianfilter = 0;
end
if length(optpar) < 9
  
  optmod = 3;
  
else
  
  optmod = optpar(9);
  
end

for i = 1:size(files,1)
  
  [data,header,obs] = inimg(files(i,:),PO);
  data = data/obs.exptime;
  [stars_azze(:,1),stars_azze(:,2)] = starpos2(ra,...
                                               decl,...
                                               obs.time(1:3),...
                                               obs.time(4:6),...
                                               obs.longlat(2),... % obs.pos(2)
                                               obs.longlat(1));   % obs.pos(1)
  
  stars_azze(:,3) = [star_list(:).HR]';
  Stars_azze = stars_azze(stars_azze(:,2)<pi/2,:);
  this_j = find(IDENTSTARS(:,1)==i);
  these_stars = IDENTSTARS(this_j,9);
  STars_azze = [];
  for j = 1:length(these_stars)
    if any(Stars_azze(:,3)==these_stars(j))
      STars_azze = [STars_azze;Stars_azze(Stars_azze(:,3)==these_stars(j),:)];
    end
  end
  star_int_model(data,optpar,optpar(9),STars_azze,STARPARS(this_j,:),OPS,IDENTSTARS(this_j,9));
end
ok = 1;
