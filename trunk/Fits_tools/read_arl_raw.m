function [d,o] = read_arl_raw(filename)
% READ_ARL_RAW - reads Airforce research labs (Todd Pedersen's) raw image format
%   (nxn uint16 block).
%
% Calling:
%   [d,o] = read_arl_raw(filename)
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
  d = fread(fp,[N N],'uint16');
  
else
  
  N = (filename.bytes/2)^(1/2);
  fp = fopen(filename.name,'r');
  d = fread(fp,[N N],'uint16');
  
end

fclose(fp);% Delta junction: 63.818168,-144.890678

o.time = d(1:6,1)';
o.time = time_fix(o.time);

o.filter = d(7,1)';

lat = d(10:12,1)';
long = d(13:15,1)';
lat = sum((lat-2^16*(lat>90)).*[1,1/60,1/60^2]);
if any(long>30000)
  long = sum((long-2^16*(long>180)).*[1,1/60,1/60^2]);
else
  long = sum(long.*[1,1/60,1/60^2]);
end
o.pos = [long,lat];
o.pos = [-144.890678,63.818168];
o.longlat = [-144.890678,63.818168];

o.size = d(22:23,1)';
o.exptime = d(9,1)' ;
o.camnr = 0;
o.beta = [];
o.alfa = [];
o.az = 0;
o.ze = 0;
o.station = 402;

function time_out = time_fix(time_in)
% TIME_FIX - 
%   

time_out = time_in;
time_out(end) = time_out(end)+10;
if time_out(end) >= 60
  
  time_out(end) = time_out(end)-60;
  time_out(end-1) = time_out(end-1) +1;
  if time_out(end-1) >= 60
    time_out(end-1) =  time_out(end-1) -60;
    time_out(end-2) = time_out(end-2) +1;
  end
  
end
