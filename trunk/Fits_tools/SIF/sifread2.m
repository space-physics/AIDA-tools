function [data,back,ref]=sifread2(file)
f=fopen(file,'r');
if f < 0
   error('Could not open the file.');
end
if ~isequal(fgetl(f),'Andor Technology Multi-Channel File')
   fclose(f);
   error('Not an Andor SIF image file.');
end
skipLines(f,1);
[data,next]=readSection(f);
if nargout > 1 & next == 1
   [back,next]=readSection(f);
   if nargout > 2 & next == 1
      ref=back;
      back=readSection(f);
   else
      ref=struct([]);
   end
else
   back=struct([]);
   ref=back;
end
fclose(f);

%Read a file section.
%
% f File handle
% info Section data
% next Flags if another section is available
%
function [info,next]=readSection(f)
o=fscanf(f,'%f',6);
info.temperature=o(6);
skipBytes(f,10);
o=fscanf(f,'%f',5);
info.exposureTime=o(2);
info.cycleTime=o(3);
info.accumulateCycles=o(5);
info.accumulateCycleTime=o(4);
skipBytes(f,2);
o=fscanf(f,'%f',2);
info.stackCycleTime=o(1);
info.pixelReadoutTime=o(2);
o=fscanf(f,'%f',3);
info.gainDAC=o(3);
skipLines(f,1);
info.detectorType=readLine(f);
info.detectorSize=fscanf(f,'%f',[1 2]);
info.fileName=readString(f);
skipLines(f,3);
skipBytes(f,14);
info.shutterTime=fscanf(f,'%f',[1 2]);
skipLines(f,8);
if strmatch('Luc',info.detectorType)
   skipLines(f,9); % Andor Luca
end
info.frameAxis=readString(f);
info.dataType=readString(f);
info.imageAxis=readString(f);
o=fscanf(f,'65538 %d %d %d %d %d %d %d %d 65538 %d %d %d %d %d %d',14);
info.imageArea=[o(1) o(4) o(6);o(3) o(2) o(5)];
info.frameArea=[o(9) o(12);o(11) o(10)];
info.frameBins=[o(14) o(13)];
s=(1 + diff(info.frameArea))./info.frameBins;
z=1 + diff(info.imageArea(5:6));
if prod(s) ~= o(8) | o(8)*z ~= o(7)
   fclose(f);
   error('Inconsistent image header.');
end
for n=1:z
   o=readString(f);
   if numel(o)
      fprintf('%s\n',o); % comments
   end
end
info.timeStamp=fread(f,1,'uint16');
skipLines(f,1);
info.imageData=reshape(fread(f,prod(s)*z,'single=>single'),[s z]);
next=fscanf(f,'%d',1);

%Read a character string.
%
% f File handle
% o String
%
function o=readString(f)
n=fscanf(f,'%d',1);
if isempty(n) | n < 0 | isequal(fgetl(f),-1)
   fclose(f);
   error('Inconsistent string.');
end
o=fread(f,[1 n],'uint8=>char');

%Read a line.
%
% f File handle
% o Read line
%
function o=readLine(f)
o=fgetl(f);
if isequal(o,-1)
   fclose(f);
   error('Inconsistent image header.');
end
o=deblank(o);

%Skip bytes.
%
% f File handle
% N Number of bytes to skip
%
function skipBytes(f,N)
[s,n]=fread(f,N,'uint8');
if n < N
   fclose(f);
   error('Inconsistent image header.');
end

%Skip lines.
%
% f File handle
% N Number of lines to skip
%
function skipLines(f,N)
for n=1:N
   if isequal(fgetl(f),-1)
      fclose(f);
      error('Inconsistent image header.');
   end
end
