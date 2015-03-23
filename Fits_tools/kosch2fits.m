function ok = kosch2fits(filename,filename_out)
% KOSCH2FITS - Transform Kosch's images to fits format.
% 
% Calling:
% ok = kosch2fits(filename,filename_out)
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

img = fread(fp,[2*384 512],'uint8');
asd = fread(fp,[10 1],'uint16');

head = 'SIMPLE  =   T';
head = char(head,'BZERO  =   -127');
head = char(head,'BITPIX  =       8');
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

if length(asd)>=9
  month = sprintf('%.2d',asd(6));
  day = sprintf('%.2d',asd(4));
  obs_time = flipud(asd(1:3));
  expt = asd(9);
  gain = asd(7:8)';
else
  month = datestr(str2num(filename(end-2:end)),5);
  day = datestr(str2num(filename(end-2:end)),7);
  obs_time = str2num([filename(3:4),' ',filename(5:6),' ',filename(7:8)]);
  expt = 1; % dont kno better!
  gain = [1 1]; %dont know better!
end
head = char(head,['DATE-OBS= ''',year,'-',month,'-',day,'T',sprintf('%.2d:%.2d:%.2d',obs_time),'''']);
head = char(head,['INSTRUME= ''Kosch''s DASI-imager 0'' /']);
head = char(head,['EXPTIME = ',num2str(expt)]);
head = char(head,['GAIN    =  ',num2str(gain)]);
head = char(head,['ALIS-STN=                      11']);
head = char(head,['ALIS-CCD=                  100100']);
head = char(head,['ZEANGLE =                       0']);
head = char(head,['AZIMUTH =                       0']);
head = char(head,'END');
head(end,80) = ' ';

fclose(fp);

if nargout ~=0
  ok = wfits(head,img,filename_out);
else
  wfits(head,img,filename_out);
end
