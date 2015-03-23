function star_list = read_all_astro_catalogs(catalog_file_nm,readme_file_nm,get_these_fields,nr_lines)
% READ_ALL_ASTRO_CATALOGS - generic astronomic catalog reader function
%   CATALOG_FILE_NM - full filename of the astronomic
%   catalog. README_FILE_NM is the full file name of the
%   READEME file for the astronomic catalog.
%
% Function not yet ready-to-run. It works by slowly and with errors
% and crashes.
% 

%   Copyright � 2001 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

tic
readme_fp = fopen(readme_file_nm,'r');
readme_l = 1;
while 1
  line = fgetl(readme_fp); 
  if ~ischar(line),
    break,
  end
  if ~isempty(line)
    readme(readme_l,1:length(line)) = line;
  end
  readme_l = readme_l+1;
end
fclose(readme_fp);

bbb_i = strmatch('Byte-by-byte',readme);
if isempty(bbb_i)
  error(['The file: ',readme_file_nm,' does not appear to be a ''proper'' README file'])
end

bbb_i = bbb_i(1)+4;
field_i = 1;
while bbb_i < size(readme,1) & ~all(readme(bbb_i,1:5)=='-') 
  
  if isempty(deblank(readme(bbb_i,1:8)))
    bbb_i = bbb_i+1; % short cut for run-on-lines
  else
    [q,w] = strtok(readme(bbb_i,1:8),' -');
    field_pos(field_i,1) = str2num(q);
    if ~isempty(deblank(w))
      field_pos(field_i,2) = str2num(strtok(w,' -'));
    else
      field_pos(field_i,2) = field_pos(field_i,1);
    end
    field_type(field_i) = readme(bbb_i,11);
    [q,w] = strtok(readme(bbb_i,15:end),' ');
    fn = strtok(w,' ');
    field_name(field_i,1:length(fn)) = fn;
    field_i = field_i+1;
    bbb_i = bbb_i+1;
    
  end
end
%ii = find(field_name(:) == '-');
%field_name(ii) = '_';
%ii = find(field_name(:) == '+');
%field_name(ii) = '_';
%ii = find(field_name(:) == '/');
%field_name(ii) = '_';
%ii = find(field_name(:) == '*');
%field_name(ii) = '_';
%ii = find(field_name(:) == '(');
%field_name(ii) = '_';
%ii = find(field_name(:) == ')');
%field_name(ii) = '_';
%ii = find(field_name(:) == '[');
%field_name(ii) = '_';
%ii = find(field_name(:) == ']');
%field_name(ii) = '_';
%ii = find(field_name(:) == '{');
%field_name(ii) = '_';
%ii = find(field_name(:) == '}');
%field_name(ii) = '_';

field_name(field_name(:) == '-') = '_';
field_name(field_name(:) == '+') = '_';
field_name(field_name(:) == '/') = '_';
field_name(field_name(:) == '*') = '_';
field_name(field_name(:) == '(') = '_';
field_name(field_name(:) == ')') = '_';
field_name(field_name(:) == '[') = '_';
field_name(field_name(:) == ']') = '_';
field_name(field_name(:) == '{') = '_';
field_name(field_name(:) == '}') = '_';

cl = 1;
catalog_fp = fopen(catalog_file_nm,'r');

if nargin ~= 4
  Nr_lines = inf;
else
  Nr_lines = nr_lines;
end
% $$$ while ( cl < Nr_lines+1 )
% $$$   line = fgetl(catalog_fp); 
% $$$   if ~isstr(line),
% $$$     break,
% $$$   end
% $$$   catalog(cl,1:length(line)) = line;
% $$$   catalog(cl,end+1) = ' ';
% $$$   cl = cl+1;
% $$$ end
% quick reading of the star catalog(s)
catalog = fread(catalog_fp);
fclose(catalog_fp);

% transforming the catalog to characters
catalog = char(catalog');
% find the linebreaks
nlstr = sprintf('\n');
nl_indx = [0 findstr(catalog,nlstr)];


if nargin < 3 || ~length(get_these_fields)
  get_these_fields = 1:length(field_type);
end
if ( nargin ~= 4 )
  %nr_lines = size(catalog,1);
  nr_lines = length(nl_indx)-1;
end
%star_list = [];

%for ii = nr_lines:-1:1,

for ii = nr_lines:-1:2,
  %for ii = 1:nr_lines,
  catalogl(1:(nl_indx(ii)-nl_indx(ii-1))) = catalog(nl_indx(ii-1)+1:nl_indx(ii));
  for fi = get_these_fields,
    %pause
    %disp([fi field_pos(fi,1) field_pos(fi,2)])
    switch field_type(fi)
     case 'A'
      %str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = catalog(ii,field_pos(fi,1):field_pos(fi,2));'];
      %eval(str_ini)
      str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = catalogl(field_pos(fi,1):field_pos(fi,2));'];
      eval(str_ini)
     case 'I'
      %str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = str2num(catalog(ii,field_pos(fi,1):field_pos(fi,2)));'];
      %eval(str_ini)
      str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = str2num(catalogl(field_pos(fi,1):field_pos(fi,2)));'];
      eval(str_ini)
     case 'F'
      %str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = str2num(catalog(ii,field_pos(fi,1):field_pos(fi,2)));'];
      %eval(str_ini)
      str_ini = ['star_list(ii).',deblank(field_name(fi,:)),' = str2num(catalogl(field_pos(fi,1):field_pos(fi,2)));'];
      eval(str_ini)
     otherwise
    end
% $$$     disp(catalogl)
% $$$     disp([field_pos(fi,1) field_pos(fi,2)])
% $$$     disp(field_type(fi))
% $$$     star_list(ii)
  end
  %disp(ii)
  %keyboard
end
% $$$   for fi = get_these_fields,
% $$$     switch field_type(fi)
% $$$      case 'A'
% $$$       star_list(ii) = setfield(star_list(ii),...
% $$$                                {ii},...
% $$$                                deblank(field_name(fi,:)),...
% $$$                                catalog(ii,field_pos(fi,1):field_pos(fi,2)));
% $$$       %disp([deblank(field_name(fi,:)),' ',field_type(fi),' ',catalog(ii,field_pos(fi,1):field_pos(fi,2))])
% $$$       %disp([field_pos(fi,1) field_pos(fi,2)])
% $$$      case 'I'
% $$$       star_list(ii) = setfield(star_list(ii),...
% $$$                                {ii},...
% $$$                                deblank(field_name(fi,:)),...
% $$$                                str2num(catalog(ii,field_pos(fi,1):field_pos(fi,2))));
% $$$       %disp([deblank(field_name(fi,:)),' ',field_type(fi),' ',catalog(ii,field_pos(fi,1):field_pos(fi,2))])
% $$$       %disp([field_pos(fi,1) field_pos(fi,2)])
% $$$      case 'F'
% $$$       star_list(ii) = setfield(star_list(ii),...
% $$$                                {ii},...
% $$$                                deblank(field_name(fi,:)),...
% $$$                                str2num(catalog(ii,field_pos(fi,1):field_pos(fi,2))));
% $$$       %disp([deblank(field_name(fi,:)),' ',field_type(fi),' ',catalog(ii,field_pos(fi,1):field_pos(fi,2))])
% $$$       %disp([field_pos(fi,1) field_pos(fi,2)])
% $$$      otherwise
% $$$     end
% $$$   end
toc
