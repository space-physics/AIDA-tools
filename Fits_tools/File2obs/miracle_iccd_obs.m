function obs = miracle_iccd_obs(fn);
    
% Cut out details from filename, it's the only metadata available for JPGs
%Site name
sn=fn(1:3);

%Year
y=str2num(fn(4:5));
if y >= 90 
    y = 1900+y;
else
    y = 2000+y;
end

%Month
mo = str2num(fn(6:7));


obs.time = [y,mo,str2num(fn(8:9)),str2num(fn(11:12)),...
          str2num(fn(13:14)),str2num(fn(15:16))];

%Wavelength
flt = str2num(fn(18:20));

if isempty(flt)
    obs.filter = 0;
else
    obs.filter = flt;
end

%Exposure
obs.exptime = str2num(fn(22:25));

%Ugly hack to find station number. Move to AIDAstationize...
stn_name = {'SOD','SGO','MUO','ABK','KIL1','KIL2','KEV','LYR','NAL'};
stn_num = [710,711,720,730,740,741,750,760,770];

%KIL moved autumn 2009!
if sn == 'KIL'
    sn = 'KIL1';
    if y >=2009 & mo >= 8
        sn = 'KIL2';
    end
end

isn = find(strcmp(sn,stn_name));
obs.station = stn_num(isn);
obs.camnr = stn_num(isn);

%Use default position readers
obs=AIDAstationize(obs,710); %Sodankylä is default central station. Of course!
obs.beta = [];
obs.alfa = [];
%Could search for usual rotation angles here as well...
obs.az = 0.;
obs.ze = 0.;

%Guess optical parameters: ASC no rotations
obs.optpar = [1 -1 0 0 0 0 0 0.35];
obs.optmod = 2;
%Done.
