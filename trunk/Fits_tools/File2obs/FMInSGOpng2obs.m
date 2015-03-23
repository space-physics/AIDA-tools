function obs = FMInSGOpng2obs(filename)
% FMInSGOpng2obs - Build obs-struct for FMI/SGO-png images

h = imfinfo(filename);

long = str2num(h.OtherText{strncmp({h.OtherText{:,1}},'Longitude',9),2});
lat = str2num(h.OtherText{strncmp({h.OtherText{:,1}},'Latitude',8),2});

str_date = h.OtherText{strncmp({h.OtherText{:,1}},'Date',4),2};
str_date = strrep(str_date,'-',' ');
str_time = h.OtherText{strncmp({h.OtherText{:,1}},'TimeStart1',10),2};
str_time = strrep(str_time,':',' ');
obs.time = [str2num(str_date),str2num(str_time)];
obs.pos= [long,lat];
obs.longlat = [long,lat];

obs.station = [123]; % Arbitrary station identifier, should be
                     % phased out
obs.alpha = []; % Useless
obs.beta = [];  % Useless
obs.az = [0];   % Azimuth angle of camera rotation clock-wise from
                % north 
obs.ze = [0];   % Zenith angle of camera rotation
obs.camnr = [-1];
obs.exptime = 1; % TBD
obs.filter = []; % TBD
obs.imreg = [];  
obs.BZERO = 0; % TBD
