function [d,o] = read_arl_keo(filename)
% READ_ARL_KEO - reads Airforce research labs (Todd Pedersen's) KEO image format
%   ([335 325] uint16 block).
%
% Calling:
%   [d,o] = read_arl_keo(filename)
% Input:
%   filename - filename either a string with name of file (either
%              relative of full path to file) or a struct from the
%              'dir' command (then care have to be taken that the
%              filename.name points to the file)
% Output:
%   d - data, [NxN] sized double array
%   o - observation struct holding available information of
%       observation.


%   Copyright © 20100715 Bjorn Gustavsson, <bjorn.gustavsson@irf.se>
%   This is free software, licensed under GNU GPL version 2 or later

if ischar(filename)
  
  tmp = dir(filename);
  N = (tmp.bytes/2)^(1/2);
  fp = fopen(filename,'r');
  d = fread(fp,[335 325],'uint16');
  
else
  
  N = (filename.bytes/2)^(1/2);
  fp = fopen(filename.name,'r');
  d = fread(fp,[335 325],'uint16');
  
end

fclose(fp);

o.time = d(1:6,1)';

o.filter = d(7,1)';
% TODO: check how to do this with byteswap!
lat = d(10:12,1)';
long = d(13:15,1)';
lat = sum((lat-2^16*(lat>90)).*[1,1/60,1/60^2]);
if long>30000
  long = sum((long-2^16*(long>90)).*[1,1/60,1/60^2]);
else
  long = sum(long.*[1,1/60,1/60^2]);
end  
o.pos = [-long,lat];
o.pos = [-145.157375,62.40723];
o.longlat = [-145.157375,62.40723];
%<http://maps.google.com/?ie=UTF8&ll=62.40723,-145.157375&spn=0.034349,0.108833&t=h&z=13>
o.size = d(22:23,1)';
o.exptime = d(9,1)' ;
o.camnr = 0;
o.beta = [];
o.alfa = [];
o.az = 0;
o.ze = 0;
o.station = 401;

axc = [26 302 16 292];
d = d(axc(3):axc(4),axc(1):axc(2));
