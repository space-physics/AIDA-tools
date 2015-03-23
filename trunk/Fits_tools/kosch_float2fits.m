function ok = kosch_float2fits(filename,filename_out)
% KOSCH_FLOAT2FITS - Transform Kosch's float-format images to fits format.
%   
% Calling:
% ok = kosch_float2fits(filename,filename_out)
%   
% Input:
%   FILENAME - string with filename (relative or full path) of
%              image in M. Kosch's image format for the DASI
%   FILENAME_OUT string with name (relative or full path) of the
%   fits-file to create. Header information is taken from filename
%   and end of file.
%
% See also KOSCH_DOUBLE2FITS KOSCH_FLOAT2FITS

%   Copyright � 20050110 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later


fp = fopen(filename,'r');

if fp < 0 
  
  error(['could not open file: ',filename])
  
end

img = fread(fp,[2*384 512],'float');

head = 'SIMPLE  =   T';
head = char(head,'BZERO  =   -127');
head = char(head,'BITPIX  =     -32');
head = char(head,'NAXIS   =       2');
head = char(head,'NAXIS1  =     512');
head = char(head,'NAXIS2  =     768');
head(end,18:80) = ' ';
% date and time stuff
year = str2num(filename(1:2));
if year > 80
  year = 1900+year;
else
  year = 2000+year;
end
year = sprintf('%.4d',year);

month = datestr(str2num(filename(end-2:end)),5);
day = datestr(str2num(filename(end-2:end)),7);
obs_time = str2num([filename(3:4),' ',filename(5:6),' ',filename(7:8)]);
expt = 10; % dont kno better!
gain = [1 1]; %dont know better!

headl = ['DATE-OBS= ''',year,'-',month,'-',day,'T',sprintf('%.2d:%.2d:%.2d',obs_time),''''];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['INSTRUME= ''Kosch''s DASI-imager 0'' /'];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['EXPTIME = ',num2str(expt)];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['GAIN    =  ',num2str(gain)];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['ALIS-STN=                      11'];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['ALIS-CCD=                  100100'];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['ZEANGLE =                       0'];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = ['AZIMUTH =                       0'];
headl(end+1:80) = ' ';
head = char(head,headl);
headl = 'END';
headl(end+1:80) = ' ';
head = char(head,headl);

%head
fclose(fp);

if nargout ~=0
  ok = wfits(head,img,filename_out);
else
  wfits(head,img,filename_out);
end
