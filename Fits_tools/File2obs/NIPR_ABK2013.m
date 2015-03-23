function obs = NIPR_ABK2013(filename,varargin)
% NIPR_ABK2013 - Meta-data Obs-struct from filename
%  This function is intended to work as a "try_to_be_smart_fnc"
%  function handle of the typical-pre-processing struct sent as
%  the second argument to INIMG.
%  
% Calling:
%   obs = NIPR_ABK2013(filename,varargin)
% Input:
%  filename - char array with filename. The standard Pike-imaging
%             software enumerates images sequentially.
%  varargin - a name - value sequence, where each value will be put
%             into the OBS-field of its preceeding name.
% Output:
%  OBS - Struct with meta-data for observation
% 
% Example:
%  PO.try_to_be_smart_fnc = @(filename)NIPR_ABK2013(filename,...
%                           'xyz',[0,0,0],...
%                           'longlat',[-145.1500,62.3930],...
%                           'station',401,...
%                           'time',[2011,03,29,6,21,02],...
%                           'filter',6300,...
%                           'dt',10);
% Will calculate the time of exposure from the sequence number of
% the image in FILENAME and DT (the time intervall between
% consecutive exposures), starting from the first exposure
% [2011,03,29,6,21,02].
% 
%  PO.try_to_be_smart_fnc = @(filename)NIPR_ABK2013(filename,...
%                           'xyz',[0,0,0],...
%                           'longlat',[-145.1500,62.3930],...
%                           'station',401,...
%                           'time',[2011,03,29,6,21,02],
%                           'filter',6300)
%
% Without a field for DT the time of observation is taken from the
% file creation date, which then is assumed to be the actual start
% of observation.
%
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

[fPAth,fName,fExt] = fileparts(filename);
T(1) =  str2num(fName(4:5))+2000;
T(2) =  str2num(fName(6:7));
T(3) =  str2num(fName(8:9));
T(4) =  str2num(fName(11:12));
T(5) =  str2num(fName(13:14));
T(6) =  str2num(fName(15:16)) + str2num(fName(17:18))/100;
lambda = str2num(fName(20:22));
expT =  str2num(fName(24:27));

obs.time = T;
obs.exptime = expT/1e3;
obs.filter = lambda;

obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [39];

obs.central_station = 10;
obs.station = 5;

if isfield(obs,'verbose')
  obs = obs
end
