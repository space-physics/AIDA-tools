function obs = pike2obs(filename,varargin)
% PIKE2OBS - Meta-data Obs-struct from filename
%  This function is intended to work as a "try_to_be_smart_fnc"
%  function handle of the typical-pre-processing struct sent as
%  the second argument to INIMG.
%  
% Calling:
%   obs = pike2obs(filename,varargin)
% Input:
%  filename - char array with filename. The standard Pike-imaging
%             software enumerates images sequentially.
%  varargin - a name - value sequence, where each value will be put
%             into the OBS-field of its preceeding name.
% Output:
%  OBS - Struct with meta-data for observation
% 
% Example:
%  PO.try_to_be_smart_fnc = @(filename)pike2obs(filename,...
%                           'xyz',[0,0,0],...
%                           'longlat',[-145.1500,62.3930],...
%                           'station',401,...
%                           'time',[2011,03,29,6,21,02],
%                           'filter',6300...
%                           'dt',10);
% Will calculate the time of exposure from the sequence number of
% the image in FILENAME and DT (the time intervall between
% consecutive exposures), starting from the first exposure
% [2011,03,29,6,21,02].
% 
%  PO.try_to_be_smart_fnc = @(filename)pike2obs(filename,...
%                           'xyz',[0,0,0],...
%                           'longlat',[-145.1500,62.3930],...
%                           'station',401,...
%                           'time',[2011,03,29,6,21,02],
%                           'filter',6300)
% Without a field for DT the time of observation is taken from the
% file creation date, which then is assumed to be the actual start
% of observation.
%
% AIDA_tools needs fields for TIME and LONGLAT to be be able to
% calculate the image position in azimuth and zenith. Fields for
% xyz with horizontal coordinates in (km) and/or station number is
% also expected for making triangulation/tomography-like analysis
% possible.
%
% If the observations are done in a filter sequence changin filters
% between observation a function handle can be given with
% field-name 'filterfunction', that gives the filter for image N in
% the observation sequence. If the camera is equipped with a
% filter-wheel with filters [4278, 5577 6300 7774 8446] and the
% observation sequence is:
%  4278, 5577, 6300, 5577, 7774, 8446
% a function can be defined like this:
%  fV = [4278,5577,6300,7774,8446]; % Filter array
%  fseq = [1 2 3 2 4 5];            % index for full filter sequence
%  f = @(nr) fV(fseq(rem(nr,length(fseq))+1));
% And then:
% 
%  PO.try_to_be_smart_fnc = @(filename)pike2obs(filename,...
%                           'xyz',[0,0,0],...
%                           'longlat',[-145.1500,62.3930],...
%                           'station',401,...
%                           'time',[2011,03,29,6,21,02],
%                           'filter',6300,...
%                           'filterfunction,f);
% This will assign the filter directly from the image number in the
% sequence, which will proceed as if the filter-sequence was
% without interupts and skips - which is not really reading
% meta-data but rather guess-work, albeit systematic.
%
% See also READ_IMG, INIMG, TRY_TO_BE_SMART

for i1 = 1:2:length(varargin)
  obs.(varargin{i1}) =  varargin{i1+1};
end

% Extract the running image number in the observation sequence,
% assuming it is found at the end of the filename (before the
% extension:)
[q1,q2,q3] = fileparts(filename);
% and that the character before is some kind of separator:
[t1,r] = strtok(fliplr(q2),'-._: '); 
N1 = str2num(fliplr(t1));

if ~isfield(obs,'dt')
  % If dt is not supplied in the name-value sequence just use the
  % creation-date of the file, and hope for the best.
  Q = dir(filename);
  obs.time = datevec(Q.datenum);
else
  % Otherwise use time of the first exposure and add the
  % number of incremental time-steps
  dt = obs.dt;
  
  % Decimal hours:
  decimal_hours = obs.time(end-2:end)*[1 1/60 1/3600]' + dt*N1/3600;
  % Integer Hours
  Thour = floor(decimal_hours);
  % Decimal minutes
  decimal_minutes = 60*(decimal_hours - Thour);
  % Integer minutes
  Tminute = floor(decimal_minutes);
  % Seconds
  Tseconds = 60*(decimal_minutes - Tminute);
  
  % obs.time(end) = obs.time(end) + dt*N1;
  obs.time(end-2:end) = [Thour, Tminute, Tseconds];
  
end


if isfield(obs,'filterfunction')
  obs.filter = obs.filterfunction(N1);
  obs = rmfield(obs,'filterfunction');
end

obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [39];
obs.exptime = 10;
