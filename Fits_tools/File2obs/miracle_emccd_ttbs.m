function obs = miracle_emccd_ttbs(filename)
%make Observation struct from filename
%For FMI and SGO EMCCD cameras

%Reading png headers - package pngmeta required
[status,header]=system(['pngmeta ',filename]);

if(status ~= 0)
  error('Error reading png metadata')
end

%The header contains one string with linebreaks.
%Scanning for fields with regexps

%Station no
stn = regexp(header,'Station: (\w+)\n','tokens');

switch stn{1}{1}
 
 case 'KIL'
  obs.station = 14; %Kilpis FMI hut
 
 case 'SOD'
  obs.station=15; %Pittioevaara
 
 otherwise
  obs.station=[];

end


%Date and time
%Date header
day=regexp(header,'Date: (\d{4})-(\d{2})-(\d{2})\n','tokens');

%Start of exposure
utstart=regexp(header,'TimeStart1: (\d{2}):(\d{2}):([\d\.]+)\n','tokens');

%End of exposure
utstop=regexp(header,'TimeStop1: (\d{2}):(\d{2}):([\d\.]+)\n','tokens');

%Average time of exposure
starttime=[str2num(day{1}{1}), str2num(day{1}{2}), str2num(day{1}{3}), ...
            str2num(utstart{1}{1}), str2num(utstart{1}{2}), ...
           str2num(utstart{1}{3})];

stoptime=[str2num(day{1}{1}), str2num(day{1}{2}), str2num(day{1}{3}), ...
            str2num(utstop{1}{1}), str2num(utstop{1}{2}), ...
           str2num(utstop{1}{3})];

avetime=(datenum(starttime)+datenum(stoptime))/2;


obs.time = num2str(datestr(avetime,'YYYY mm dd HH MM SS'));


%Position
lat=regexp(header,'Latitude\(Deg\): ([\d\.]+)\n','tokens');

long=regexp(header,'Longitude\(Deg\): ([\d\.]+)\n','tokens');

obs.longlat = [str2num(lat{1}{1}) str2num(long{1}{1})];
obs.pos=[str2num(lat{1}{1}) str2num(long{1}{1})];


%position error exorcism for Kilpis - Had Kevo coordinates during
%spring 2008.
if (obs.station==14 && obs.time(1)==2008 && obs.time(2)<6)
  load stationpos.dat 
  obs.longlat=[stationpos(obs.station,5:7)*[1 1/60 1/3600]',  ...
               stationpos(obs.station,1:3)*[1 1/60 1/3600]'];
  obs.pos=[stationpos(obs.station,5:7)*[1 1/60 1/3600]',  ...
           stationpos(obs.station,1:3)*[1 1/60 1/3600]'];
else
  lat=str2num(header{10,2});
  long=str2num(header{11,2});
  obs.longlat = [long,lat];
  obs.pos=[long lat];
end


%Exposure time

exptim=regexp(header,'Exposure\(s\): ([\d\*\.]+)\n','tokens');

%returns a string with the expression n*basetime
obs.exptime = eval(exptim{1}{1});


%Filter
filt=regexp(header,'Filter\(nm\): (\w+)\n','tokens');
switch deblank(filt{1}{1})
  case 'NoFilter'
   obs.filter = 0;
 case '557'
   obs.filter=5577;
 case '428'
  obs.filter=4278;
 otherwise
  %Takes care of 630 and background filters
  obs.filter=eval(filt{1}{1})*10; %nm to Ã$(B!D(B
end


%Fixed parameters

obs.alpha = [];

obs.beta = [];

obs.az = [0];

obs.ze = [0];

obs.imreg = [];

obs.camnr = -1; %No ALIS camera correction

obs.cmtr = eye(3);

obs.optmod=2; %f*sin(a*theta)
