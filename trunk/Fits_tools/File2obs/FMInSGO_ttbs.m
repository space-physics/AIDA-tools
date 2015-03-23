function obs = FMInSGO_ttbs(filename)
% FMInSGO_ttbs - Observation struct for SGO and FMI emCCD 
%  from filename.
% 
% Calling:
%  obs = FMInSGO_ttbs(filename)
%
% Input:
%  filename - char array with filename (full or relative path to file) 
%
% Output:
%  obs - struct with meta-data for image, position (lat, long),
%        time (UTC-date), exposure time, filter, station number
%        (For ALIS use), azimuth and zenith angles, alfa and beta
%        angles (For Tait Bruant angles)
%
% See also: try_to_be_smart

% Seems as matlab can get metadata from pngs.
iA = imfinfo(filename);
iA = iA.OtherText;

% Here's how to parse, right no I dont care to make it more general
% but it should be straightforward to do something similar to
% fits2obs.txt...

i1 = find_in_cellstr('Station',iA(:,1));
if ~isempty(i1)
  switch iA{i1(1),2}
   case 'SOD'
    station = 12;
   case 'KIL'
    station = 14;
   otherwise
    station = 0;
  end
end

i1 = find_in_cellstr('Latitude',iA(:,1));
if ~isempty(i1)
  obs.pos(2) = str2num(iA{i1,2});
  obs.latlong(2) = str2num(iA{i1,2});
else
  obs.pos(2) = 0;
  obs.latlong(2) = 0;
  warning(['Could not find LATITUDE for file: ',filename])
end

i1 = find_in_cellstr('Longitude',iA(:,1));
if ~isempty(i1)
  obs.pos(1) = str2num(iA{i1,2});
  obs.latlong(1) = str2num(iA{i1,2});
else
  obs.pos(1) = 0;
  obs.latlong(1) = 0;
  warning(['Could not find LONGITUDE for file: ',filename])
end


i1 = find_in_cellstr('Date',iA(:,1));
if ~isempty(i1)
  obsdate = datevec(iA{i1,2},'yyyy-mm-dd');
else
  obsdate = 0;
  warning(['Could not find DATE for file: ',filename])
end
%    'TimeStart1'           '00:14:46.94'
i1 = find_in_cellstr('TimeStart1',iA(:,1));
if ~isempty(i1)
  % Cant make this fly with fractions of a second except if time is
  % given with milliseconds...
  % obstime = datevec(iA{i1,2},'hh:mm:ss');
  % TODO: This is clumsy and static, you'd better fix
  obstime = [str2num(iA{i1,2}(1:2)),str2num(iA{i1,2}(4:5)),str2num(iA{i1,2}(7:end))];
else
  obstime = 0;
  warning(['Could not find TIMESTART1 for file: ',filename])
end

i1 = find_in_cellstr('Exposure(s)',iA(:,1));
if ~isempty(i1)
  obs.exptime = eval(iA{i1(1),2});
else
  warning(['Could not find EXPOSURE for file: ',filename])
end
obs.station = station;
obs.time = [obsdate(1:3),obstime];

% TODO: Couldn't be bothered to fix those below.
obs.filter = [];

obs.alpha = [];
obs.beta = [];
obs.az = [0];
obs.ze = [0];
obs.camnr = [-1];
obs.cmtr = eye(3);
