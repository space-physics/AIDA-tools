function ASK_enable_datadir(datadir,smartdark,flat_tromso)
% ASK_ENABLE_DATADIR - short routine to automatically enable 
%  a data directory from the ASK data acquisition 
%  system
% 
% Calling:
%   ASK_enable_datadir(datadir,smartdark,flat_tromso)
% Input:
%   datadir - The full path to the megablock you want to enable.
% Keywords:
%   smartdark - Set this so a dark from the dark-sequence just
%               before the data is created and added in the
%               description file 
%   flat_tromso - Normally flats are taken from ask.lut, but if
%                 flat_tromso is set then some hard-coded flat
%                 names are used.
%
% This function is untested, and will write setup-files - so should
% be avoided until tested carefully!

% Modified from add_multi.pro
% Copyright Bjorn Gustavsson 20110131
% GPL 3.0 or later applies

% Dan modified this 09/11/09, to look in ask.lut for the flat file name.
%

% global hities % Seems unused - never popped up as problematic 20120221
global asklut % WITH: ask_t1, ask_t2, ask_lat, ask_lon, ask_ncam, ask_uon, ask_cam, ask_cnv, ask_fps, ask_bin, ask_cal, ask_flat
global vs

% ASKLUTfile = '/stp/raid2/ask/data/setup/ask.lut';
ASK_site_setup

% posFsep = findstr(datadir,filesep);
posFsep = strfind(datadir,filesep);
aaa = datadir(posFsep(end)+1:end);

num = 0;
% yr = str2num(aaa(1:4));
% mo = str2num(aaa(5:6));
% da = str2num(aaa(7:8));
% ho = str2num(aaa(9:10));
% mi = str2num(aaa(11:12));
% se = str2num(aaa(13:14));
yr = str2double(aaa(1:4));
mo = str2double(aaa(5:6));
da = str2double(aaa(7:8));
ho = str2double(aaa(9:10));
mi = str2double(aaa(11:12));
se = str2double(aaa(13:14));

Dtype = aaa(15);
nums = aaa(16);

switch nums
 case 'A'
  ASK_read_asklut('alvis')
  num = 1;
  data_type = 'ask';
  cameranum = 'ALVIS';
  ccdx = 1004;
  ccdy = 1002;
 case  '1' 
  ASK_read_asklut(ASKLUTfile);
  num = 1;
  data_type = 'ask';
  cameranum = 'ASK #1';
  ccdx = 512;
  ccdy = 512;
 case   '2'
  ASK_read_asklut(ASKLUTfile);
  num = 2;
  data_type = 'ask';
  cameranum = 'ASK #2';
  ccdx = 512;
  ccdy = 512;
 case '3'
  ASK_read_asklut(ASKLUTfile);
  num = 3;
  data_type = 'ask';
  cameranum = 'ASK #3';
  ccdx = 512;
  ccdy = 512;
 otherwise
  disp(['Unknown Dtype ID: ',nums])
end

% b = findstr(aaa,'w');
b = strfind(aaa,'w');
if ~isempty(b)
  prefix = 'mean-';
else 
  prefix = 'image-';
end

mjs = ASK_TT_MJS([yr,mo,da,ho,mi,se]);

[sta,sto] = ASK_locate_int(asklut.ask_t1, asklut.ask_t2, mjs, mjs);
latitude  = asklut.ask_lat(sta);
longitude = asklut.ask_long(sta);

filter     = asklut.ask_cam{num, sta};
time_res   = 1.0/asklut.ask_fps(num, sta);
if ~isempty(sta) & sta <= size(asklut.ask_flat,2)
  flat_field = asklut.ask_flat{num,sta};
 else
   flat_field = '';
end

% writing here the information on the description file
%
description_name = [aaa,'.txt'];
if num == asklut.ask_uon(sta)
  data_type = [data_type,'3'];
end
if Dtype == 'd'
  data_type = [data_type,'d'];
end
start_num = 1;

if exist(datadir,'dir') ~= 7
  disp('Error: data directory does not exist!')
  return
end

[status,aaaa] = system(['ls ',datadir,' | grep ',prefix(1:end-1),' |wc']);
n_files  = sscanf(aaaa,'%d');

if strcmp(prefix(1:end-1),'image')
  
  [status,aaaa] = system(['ls ',datadir,' | grep ',prefix(1:end-1),' |head -1']);
  % if findstr('images-',aaaa)
  if strfind(aaaa,'images-')
    n_files = (n_files/time_res)*2; % For v8 data, ASK saves 1 file every 2 seconds
    data_type = [data_type,'v8']; % data_type+='v8'
    prefix = 'images-';
  end
  
end

% reads, aaaa, n_files
stop_num = n_files(1);
nstep    = 1;

if ~isempty(b)
  nstep     = 2*asklut.ask_fps(num, sta);
  start_num = nstep+1;
  stop_num  = fix(n_files(1)*nstep+1);
end

%if type eq 'd' then stop_num = '100'
disp(['Enabling data directory: ', description_name])
disp(['Consider changing filename: ', description_name,' to: ',lower(description_name)])
dark_field = 'nodark';

if Dtype == 'd' 
  flat_field = 'noflat';
%elseif length(strtrim(flat_field)) < 1
elseif length(flat_field) < 1
  disp('Warning! No flat file listed in lookup table, using noflat.')
  flat_field = 'noflat';
end
%%%%%PUT IN FLATS DIRECTLY!! Changed by Hanna on 11/6 2007. Now the
%%%%%flats for 2006/2007 are put into the description files directly,
%%%%%if the keyword flat_tromso is set.
if nargin == 3 & flat_tromso
 disp('Overriding flat file due to flat_tromso keyword.')
 switch filter
  case 6730
   flat_field = 'flat_oct06_6730.dat';
  case 7320
   flat_field = 'flat_dec06_7320.dat';
  case 7774
   flat_field = 'flat_dec06_7774.dat';
  case 5620
   flat_field = 'flat_dec06_5620.dat';
  case 4278
   flat_field = 'flat_4278_feb07.dat';
  otherwise
 end
end

if isempty(b)
  if nargin > 1 & ~isempty(smartdark) & smartdark
    % this bit for automatic inclusion of the dark field 
    [dark_name,dark_short] = ASK_get_dark_name(datadir);
    ASK_enable_datadir(dark_name);
    ASK_make_askdark(dark_short);
    dark_field = [dark_short,'.dark'];
  end
end
if exist(fullfile(vs.videodir,'/setup/',description_name),'file') == 2
  [status, message] = backup1000filesversions(fullfile(vs.videodir,'/setup/',description_name));
end
fID = fopen(fullfile(vs.videodir,'/setup/',description_name),'w');
%fID = fopen(fullfile('/home/bjg1c10',description_name),'w');
fprintf( fID, '# This is an automatically created event description file\n');
fprintf( fID, '%s\n',cameranum);
fprintf( fID, '%s\n',aaa);
% Added by Hanna and Dan 11/08/2010:
%%%  if exist(fullfile(videodir,+aaa,/DANGLING_SYMLINK) eq 1) then spawn, 'rm '+videodir+'/'+aaa
% This test never worked, as videodir is usually specified as "$VIDEODIR/".
% We just end up with loads of recursive soft links in a nasty hall of mirrors
% type effect.
%if (datadir ne videodir+'/'+aaa) then spawn, 'ln -s '+datadir+' '+videodir+'/'+aaa
% So Dan changed it to this, 03/11/2009:
%%%  if (file_test(videodir+'/'+aaa) eq 0) then spawn, 'ln -s '+datadir+' '+videodir+'/'+aaa
% Not quite exactly what we want, but the best I can think of right now,
% and better than the previous test.
fprintf(fID,'%s\n',  prefix);
fprintf(fID,'%4d %02d %02d %02d %02d %02d 000\n',yr,mo,da,ho,mi,round(se)); %  form = '(i4.4,5i3.2,i4.3)'
fprintf(fID,'%d %d\n',start_num, nstep);       % start number file-number increment
fprintf(fID,'%d\n', stop_num);                 % stop number
fprintf(fID,'%f\n', time_res);
fprintf(fID,'%s\n',  filter);
fprintf(fID,'%f\n',  latitude);
fprintf(fID,'%f\n',  longitude);
fprintf(fID,'setup/%s\n',strtrim(asklut.ask_cnv{num,sta}));
npx = ccdx/asklut.ask_bin(num,sta);
npy = ccdy/asklut.ask_bin(num,sta);
fprintf(fID,'%d  %d\n',  npx,npy);
fprintf(fID,'%s\n',  data_type  );
fprintf(fID,'%s\n',  dark_field );
fprintf(fID,'%s\n',  strtrim(flat_field) );
fclose( fID );


% $$$ disp('Have you tested that this function does not ruin existing')
% $$$ disp('setup-files?')
% $$$ disp('If you have not then this is the time to escape disaster')
% $$$ disp('by typing:')
% $$$ disp('dbquit')
% $$$ disp('after the prompt. Otherwise just type:')
% $$$ disp('return')
% $$$ disp('after the prompt to continue with enabling the data directory.')
% $$$ keyboard
%
%  first locate the start time information
%
